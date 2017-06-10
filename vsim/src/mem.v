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
              //$display("Clk: addr: %d en:  %d we:  %d din:  %d dout:  %d mask:  %d mem: ", addra, ena, wea, dina, douta, maska );
          end else begin
              douta = mem[addra] & maska;
              //$display("Clk: addr: %d en:  %d we:  %d din:  %d dout:  %d mask:  %d mem: ", addra, ena, wea, dina, douta, maska );
          end
       end

       maskb = { {8{enb[3]}}, {8{enb[2]}}, {8{enb[1]}}, {8{enb[0]}} };
       if (enb) begin
          if (web) begin
              mem[addrb] = dinb & maskb;
              //$display("Clk: addr: %d en:  %d we:  %d din:  %d dout:  %d mask:  %d mem: ", addra, ena, wea, dina, douta, mask );
          end else begin
              doutb = mem[addrb] & maskb;
              //$display("Clk: addr: %d en:  %d we:  %d din:  %d dout:  %d mask:  %d mem: ", addra, ena, wea, dina, douta, mask );
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
      mem[0] = 32'h00108093;
      mem[1] = 32'h00000013;
      mem[2] = 32'hffdff06f;

      mem[32] = 32'h00000013;
      mem[33] = 32'h00108093;
      mem[34] = 32'h00000013;
      mem[35] = 32'h00000013;
      mem[36] = 32'hff1ff06f;
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
