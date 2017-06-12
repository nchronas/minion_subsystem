`timescale 1ns / 1ps

module datamem(
                input clk,
                input [31:0] dina,
                input [13:0] addra,
                input [0:0] wea,
                input [3:0] ena,
                output [31:0] douta,
                input [31:0] dinb,
                input [13:0] addrb,
                input [0:0] web,
                input [3:0] enb,
                output [31:0] doutb
                );

    reg [31:0] mem [16384:0];
    //initial $readmemh("code.mem1", mem);

    wire [31:0] maska, maskb;

    always @(posedge clk) begin
       maska = { {8{ena[3]}}, {8{ena[2]}}, {8{ena[1]}}, {8{ena[0]}} };
       if (ena) begin
          if (wea) begin
              mem[addra] = dina & maska;
              $display("Mem A ",
                       "addr: %x ", addra,
                         "en: %x ", ena,
                         "we: %x ", wea,
                        "din: %x ", dina,
                       "dout: %x ", douta,
                       "mask: %x ", maska,
                        "mem: %x ", mem[addra]);
          end else begin
              douta = mem[addra] & maska;
              $display("Mem A ",
                       "addr: %x ", addra,
                         "en: %x ", ena,
                         "we: %x ", wea,
                        "din: %x ", dina,
                       "dout: %x ", douta,
                       "mask: %x ", maska,
                        "mem: %x ", mem[addra]);
         end
       end

       maskb = { {8{enb[3]}}, {8{enb[2]}}, {8{enb[1]}}, {8{enb[0]}} };
       if (enb) begin
          if (web) begin
              mem[addrb] = dinb & maskb;
              $display("Mem B ",
                       "addr: %x ", addrb,
                         "en: %x ", enb,
                         "we: %x ", web,
                        "din: %x ", dinb,
                       "dout: %x ", doutb,
                       "mask: %x ", maskb,
                        "mem: %x ", mem[addrb]);
          end else begin
              doutb = mem[addrb] & maskb;
              $display("Mem B ",
                       "addr: %x ", addrb,
                         "en: %x ", enb,
                         "we: %x ", web,
                        "din: %x ", dinb,
                       "dout: %x ", doutb,
                       "mask: %x ", maskb,
                        "mem: %x ", mem[addrb]);
          end
       end
    end
endmodule

module progmem(
                input clk,
                input [31:0] dina,
                input [13:0] addra,
                input [0:0] wea,
                input [3:0] ena,
                output [31:0] douta,
                input [31:0] dinb,
                input [13:0] addrb,
                input [0:0] web,
                input [3:0] enb,
                output [31:0] doutb
                );

    reg [31:0] mem [16384:0];
    //initial $readmemh("code.mem1", mem);

    wire [31:0] maska, maskb;

    initial begin

      mem[32] = 32'h00000013;
      mem[33] = 32'h00108093;
      mem[34] = 32'h00000013;
      mem[35] = 32'h00000013;
      mem[36] = 32'h00000013;

      mem[37] = 32'h07500313;
      mem[38] = 32'h002003b7;
      mem[39] = 32'h0063a023;

      mem[40] = 32'h00000013;
      mem[41] = 32'h00000013;
      mem[42] = 32'h00000013;

      mem[43] = 32'h001002b7;

      mem[44] = 32'h0012a023;
      mem[45] = 32'h00000013;

      mem[46] = 32'h0002a103;
      mem[47] = 32'h00000013;
      mem[48] = 32'h0002a183;
      mem[49] = 32'h00000013;
      mem[50] = 32'h00218193;
      mem[51] = 32'h00000013;
      mem[52] = 32'h0032a023;
      mem[53] = 32'h00000013;
      mem[54] = 32'h00000013;
      mem[55] = 32'hfbdff06f;

//      mem[] = 32'h;
    end

    always @(posedge clk) begin
       maska = { {8{ena[3]}}, {8{ena[2]}}, {8{ena[1]}}, {8{ena[0]}} };
       if (ena) begin
          if (wea) begin
              mem[addra] = dina & maska;
              $display("Prog A ",
                       "addr: %x ", addra,
                         "en: %x ", ena,
                         "we: %x ", wea,
                        "din: %x ", dina,
                       "dout: %x ", douta,
                       "mask: %x ", maska,
                        "mem: %x ", mem[addra]);

          end else begin
              douta = mem[addra] & maska;
              $display("Prog A ",
                       "addr: %x ", addra,
                         "en: %x ", ena,
                         "we: %x ", wea,
                        "din: %x ", dina,
                       "dout: %x ", douta,
                       "mask: %x ", maska,
                        "mem: %x ", mem[addra]);
          end
       end

       maskb = { {8{enb[3]}}, {8{enb[2]}}, {8{enb[1]}}, {8{enb[0]}} };
       if (enb) begin
          if (web) begin
              mem[addrb] = dinb & maskb;
              $display("Prog B ",
                       "addr: %x ", addrb,
                         "en: %x ", enb,
                         "we: %x ", web,
                        "din: %x ", dinb,
                       "dout: %x ", doutb,
                       "mask: %x ", maskb,
                        "mem: %x ", mem[addrb]);
          end else begin
              doutb = mem[addrb] & maskb;
              $display("Prog B ",
                       "addr: %x ", addrb,
                         "en: %x ", enb,
                         "we: %x ", web,
                        "din: %x ", dinb,
                       "dout: %x ", doutb,
                       "mask: %x ", maskb,
                        "mem: %x ", mem[addrb]);
          end
       end
    end
endmodule
