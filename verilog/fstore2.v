// A simple monitor (LCD display) driver with glass TTY behaviour in text mode

module fstore2(
               input             pixel2_clk,
               output reg [7:0]  red,
               output reg [7:0]  green,
               output reg [7:0]  blue,

               output [11:0]     DVI_D,
               output            DVI_DE,
               output            DVI_H,
               output            DVI_V,
               output            DVI_XCLK_N,
               output            DVI_XCLK_P,

               output            vsyn,
               output reg        hsyn,
               output reg        blank,

               output wire [7:0] doutb,
               input wire [7:0]  dinb,
               input wire [12:0] addrb,
               input wire        web, enb,
               input wire        clk_data,
               input wire        irst,

               input             GPIO_SW_C,
               input             GPIO_SW_N,
               input             GPIO_SW_S,
               input             GPIO_SW_E,
               input             GPIO_SW_W
               );

   wire                          clear = GPIO_SW_S & GPIO_SW_N; 
   
   parameter rwidth = 14;

   wire                          m0 = 1'b0;
   wire                          dvi_mux;
   assign DVI_XCLK_P = !dvi_mux;  // Chrontel defaults to clock doubling mode
   assign DVI_XCLK_N = dvi_mux;   // where both edges of this mark a 12-bit word.
   //assign DVI_RESET_B = !dvi_reset;

   assign DVI_D[11:8] = (m0 || blank) ? 4'h0 : (dvi_mux) ? red[7:4]: green[3:0];
   assign DVI_D[7:4]  = (m0 || blank) ? 4'h0 : (dvi_mux) ? red[3:0]: blue[7:4];
   assign DVI_D[3:0]  = (m0 || blank) ? 4'h0 : (dvi_mux) ? green[7:4]: blue[3:0];
   assign DVI_H = hsyn;      
   assign DVI_V = vsyn;

   assign DVI_DE = !blank;
   
   reg                           vblank;

   reg                           hstart, hstop, vstart, vstop;
   reg [12:6]                    offhreg,scrollh;
   reg [5:3]                     offpixel;
   reg [11:5]                    offvreg,scrollv;
   reg [4:1]                     vrow;
   reg [4:0]                     scroll;
   
   wire [7:0]                    dout;
   wire [12:0]                   addra = {offvreg[10:5],offhreg[12:6]};
   
   // 100 MHz / 2100 is 47.6kHz.  Divide by further 788 to get 60.4 Hz.
   // Aim for 1024x768 non interlaced at 60 Hz.  
   
   reg [11:0]                    hreg, vreg;

   reg                           bitmapped_pixel;
   
   wire [7:0]                    red_in, green_in, blue_in;
   assign dvi_mux = hreg[0];

   dualmem ram1(.clka(pixel2_clk),
                .dina(addra[7:0]), .addra(addra), .wea(clear), .douta(dout), .ena(1'b1),
                .clkb(clk_data), .dinb(dinb), .addrb(addrb), .web(web), .doutb(doutb), .enb(enb));
   
   always @(posedge pixel2_clk) // or posedge reset) // JRRK - does this need async ?
   if (irst)
     begin
        hreg <= 0;
        hstart <= 0;
        hsyn <= 0;
        hstop <= 0;
        vreg <= 0;
        vstart <= 0;
        vstop <= 0;
        vblank <= 0;
        red <= 0;
        green <= 0;
        blue <= 0;
        bitmapped_pixel <= 0;
        blank <= 0;
        offhreg <= 0;
        offvreg <= 0;
        offpixel <= 0;
        vrow <= 0;
        scroll <= 0;
        scrollh <= 0;
        scrollv <= 0;
     end
   else
     begin
        hreg <= (hstop) ? 0: hreg + 1;
        hstart <= hreg == 2048;      
        if (hstart) hsyn <= 1; else if (hreg == (2048+20)) hsyn <= 0;
        hstop <= hreg == (2100-1);
        if (hstop) begin
           if (vstop)
             begin
                vreg <= 0;
                scroll <= {GPIO_SW_N,GPIO_SW_S,GPIO_SW_E,GPIO_SW_W,GPIO_SW_C};
                if ((scrollv>0) && GPIO_SW_N & ~scroll[4]) scrollv <= scrollv - 4;
                if ((scrollv<32) && GPIO_SW_S & ~scroll[3]) scrollv <= scrollv + 4;
                if ((scrollh<96) && GPIO_SW_E & ~scroll[2]) scrollh <= scrollh + 4;
                if ((scrollh>0) && GPIO_SW_W & ~scroll[1]) scrollh <= scrollh - 4;
                if (GPIO_SW_C & ~scroll[0]) begin scrollh <= 0; scrollv <= 0; end
             end
           else
             vreg <= vreg + 1;
           vstart <= vreg == 768;
           vstop <= vreg == 768+19;
        end

        vblank <= vreg < 10 || vreg >= 768+10; 
        
        if (dvi_mux) begin
           red <= red_in;         
           blue <= blue_in;
           green <= green_in;
        end

        if (vreg >= 32 && vreg < 32+768)
          begin
             if (hreg >= 128*3 && hreg < (128*3+256*6))
               begin
                  if (&hreg[1:0])
                    begin
                       if (offpixel == 5)
                         begin
                            offpixel <= 0;
                            offhreg <= offhreg+1;
                         end
                       else
                         offpixel <= offpixel+1;
                    end
                  bitmapped_pixel <= 1;
               end
             else
               begin
                  offpixel <= 0;
                  offhreg <= scrollh;
                  if (hstop & vreg[0])
                    begin
                       if (vrow == 11)
                         begin
                            vrow <= 0;
                            offvreg <= offvreg+1;
                         end
                       else
                         begin
                            vrow <= vrow + 1;
                         end
                    end
                  bitmapped_pixel <= 0;
               end
          end
        else
          begin
             vrow <= 0;
             offvreg <= scrollv;
             bitmapped_pixel <= 0;
          end
        
        
        blank<= hsyn | vsyn | vblank;
        
     end

   assign vsyn = vstart;
   
   wire [7:0] pixels_out;
   chargen_7x5_rachel the_rachel(
                                 .clk(pixel2_clk),
                                 .char(dout),
                                 .row(vrow),
                                 .pixels_out(pixels_out));
   
   wire       pixel = pixels_out[3'd7 ^ offpixel] && bitmapped_pixel;

   assign red_in = (pixel ? 8'hff: 8'h00);
   assign green_in = (pixel ? 8'hff: 8'h00);
   assign blue_in   = 8'b0;
   
endmodule
