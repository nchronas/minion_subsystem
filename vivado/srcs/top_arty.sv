`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/11/2017 04:57:34 PM
// Design Name: 
// Module Name: top_arty
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_arty(

    //! LEDs.
    output [7:0] LED,
 
    // clock and reset
    input         CLK100MHZ,
    input         ck_rst,

    output wire 	  uart_rxd_out,
    input wire        uart_txd_in,
    
    // pusb button array
    input [3:0] btn

);
    
      clk_wiz_arty_0 clk_gen
     (
     .clk_in1     ( CLK100MHZ     ), // 100 MHz onboard
     .clk_out1    ( clk_200MHz    ), // 200 MHz
     .clk_out2    ( msoc_clk      ), // 25 MHz (for minion SOC)
     .clk_out3    ( pxl_clk       ),
      // Status and control signals
        .reset      ( ck_rst       ),
        .locked      ( clk_locked    )
        );
  
     minion_soc
       msoc (
           .clk_200MHz (clk_200MHz),
           .msoc_clk(msoc_clk),
           
           
           .from_dip(i_dip),
           .to_led(o_led),
           .rstn(clk_locked)
  );
endmodule
