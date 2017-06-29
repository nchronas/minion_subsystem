// Copyright 2015 ETH Zurich, University of Bologna, and University of Cambridge
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
// See LICENSE for license details.

`include "config.sv"
`default_nettype none

module minion_soc
  (
 output wire 	   uart_tx,
 input wire 	   uart_rx,
 // clock and reset
 //input wire        clk_200MHz,
 //input wire        pxl_clk,
 input wire 	   clk_in1,
 input wire 	   rstn,//,
 output reg [7:0]  to_led
 //input wire [15:0] from_dip,
 //output wire [31:0] 	   core_lsu_addr,
 //output reg  [31:0] 	   core_lsu_addr_dly,
 //output wire [31:0] 	   core_lsu_wdata,
 //output wire [3:0] 	   core_lsu_be,
 //output wire	   ce_d,
 //output wire	   we_d,
 //output wire	   shared_sel,
 //input wire [31:0] 	   shared_rdata,
 // pusb button array
 //input wire GPIO_SW_C,
 //input wire GPIO_SW_W,
 //input wire GPIO_SW_E,
 //input wire GPIO_SW_N,
 //input wire GPIO_SW_S

 );

 wire [19:0] dummy;

 wire 	   msoc_clk;
 wire [31:0] 	   core_lsu_addr;
 reg  [31:0] 	   core_lsu_addr_dly;
 wire [31:0] 	   core_lsu_wdata;
 wire [3:0] 	   core_lsu_be;
 wire	   ce_d;
 wire	   we_d;
 wire	   shared_sel;
 wire [31:0] 	   shared_rdata;

//----------------------------------------------------------------------------//
// Core Instantiation
//----------------------------------------------------------------------------//
// signals from/to core
logic         core_instr_req;
logic         core_instr_gnt;
logic         core_instr_rvalid;
logic [31:0]  core_instr_addr;

logic         core_lsu_req;
logic         core_lsu_gnt;
logic         core_lsu_rvalid;
logic         core_lsu_we;
logic [31:0]  core_lsu_rdata;

  logic                  debug_req = 1'b0;
  logic                  debug_gnt;
  logic                  debug_rvalid;
  logic [14:0]           debug_addr = 15'b0;
  logic                  debug_we = 1'b0;
  logic [31: 0]          debug_wdata = 32'b0;
  logic [31: 0]          debug_rdata;
  logic [31: 0]          core_instr_rdata;

  logic        fetch_enable_i = 1'b1;
  logic [31:0] irq_i = 32'b0;
  logic        core_busy_o;
  logic        clock_gating_i = 1'b1;
  logic [31:0] boot_addr_i = 32'h80;
  logic  [7:0] core_lsu_rx_byte;

  logic [15:0] one_hot_data_addr;
  logic [31:0] one_hot_rdata[15:0];

  assign shared_sel = one_hot_data_addr[8];

riscv_core
#(
  .N_EXT_PERF_COUNTERS ( 0 )
)
RISCV_CORE
(
  .clk_i           ( msoc_clk          ),
  .rst_ni          ( rstn              ),

  .clock_en_i      ( 1'b1              ),
  .test_en_i       ( 1'b0              ),

  .boot_addr_i     ( boot_addr_i       ),
  .core_id_i       ( 4'h0              ),
  .cluster_id_i    ( 6'h0              ),

  .instr_addr_o    ( core_instr_addr   ),
  .instr_req_o     ( core_instr_req    ),
  .instr_rdata_i   ( core_instr_rdata  ),
  .instr_gnt_i     ( core_instr_gnt    ),
  .instr_rvalid_i  ( core_instr_rvalid ),

  .data_addr_o     ( core_lsu_addr     ),
  .data_wdata_o    ( core_lsu_wdata    ),
  .data_we_o       ( core_lsu_we       ),
  .data_req_o      ( core_lsu_req      ),
  .data_be_o       ( core_lsu_be       ),
  .data_rdata_i    ( core_lsu_rdata    ),
  .data_gnt_i      ( core_lsu_gnt      ),
  .data_rvalid_i   ( core_lsu_rvalid   ),
  .data_err_i      ( 1'b0              ),

  .irq_i           ( irq_i             ),

  .debug_req_i     ( debug_req         ),
  .debug_gnt_o     ( debug_gnt         ),
  .debug_rvalid_o  ( debug_rvalid      ),
  .debug_addr_i    ( debug_addr        ),
  .debug_we_i      ( debug_we          ),
  .debug_wdata_i   ( debug_wdata       ),
  .debug_rdata_o   ( debug_rdata       ),
  .debug_halted_o  (                   ),
  .debug_halt_i    ( 1'b0              ),
  .debug_resume_i  ( 1'b1              ),

  .fetch_enable_i  ( fetch_enable_i    ),
  .core_busy_o     ( core_busy_o       ),

  .ext_perf_counters_i (  2'b0         )
);

memconfig memmux {
  //from core lsu
  .core_lsu_addr(core_lsu_addr) ,
  .core_lsu_wdata(core_lsu_wdata) ,
  .core_lsu_we(core_lsu_we) ,
  .core_lsu_req(core_lsu_req) ,
  .core_lsu_be(core_lsu_be) ,
  core_lsu_rdata(core_lsu_rdata) ,
  .core_lsu_gnt(core_lsu_gnt) ,
  .core_lsu_rvalid(core_lsu_rvalid) ,

  //minion bus to peripherals
  .bus_addr(minion_bus_addr),

  //bus enable
  .bus_ce(minion_bus_ce),
  .bus_we(minion_bus_we),

  .bus_read(minion_bus_read),
  .bus_write(minion_bus_write)

}

//----------------------------------------------------------------------------//
// Data RAM
//----------------------------------------------------------------------------//

datamem block_d (
  .clk(msoc_clk),
  .wea(minion_bus_we[BLOCK_D]),
  .ena(minion_bus_we[BLOCK_D] ? core_lsu_be : 4'b1111),
  .addra(minion_bus_addr[15:2]),
  .dina(core_lsu_wdata),
  .douta(minion_bus_read[block_d_rdata_addr]),
  .web(1'b0),
  .enb(4'b0000),
  .addrb(minion_bus_addr[15:2]),
  .dinb(core_lsu_wdata),
  .doutb()
 );

//----------------------------------------------------------------------------//
// Instruction RAM
//----------------------------------------------------------------------------//
   logic 	ce_i;
   logic  we_i;

   coremem coremem_i
   (
    .clk_i(msoc_clk),
    .rst_ni(rstn),
    .data_req_i(core_instr_req),
    .data_gnt_o(core_instr_gnt),
    .data_rvalid_o(core_instr_rvalid),
    .data_we_i(1'b0),
    .CE(ce_i),
    .WE(we_i)
    );

progmem block_i (
    .clk(msoc_clk),
    .wea(1'b0),
    .ena(4'b1111),
    .addra(core_instr_addr[15:2]),
    .dina(32'b0),
    .douta(core_instr_rdata),
    .web(minion_bus_we[BLOCK_I]),
    .enb(minion_bus_we[BLOCK_I] ? core_lsu_be : 4'b1111),
    .addrb(minion_bus_addr[15:2]),
    .dinb(core_lsu_wdata),
    .doutb(minion_bus_read[block_i_rdata_addr])
   );

  //////////////////////////////////////////////////////////////////
  ///                                                            ///
  /// APB Slave 0: APB UART interface                            ///
  ///                                                            ///
  //////////////////////////////////////////////////////////////////

leds my_leds
  (
   // Clock and Reset
   .clk(msoc_clk),
   .rst(!rstn),

   //I/O wires to pins
   .leds(to_led),

   //bus SFR enable
   .bus_re(minion_bus_ce[LEDS_CE]),
   .bus_we(minion_bus_we[LEDS_WE]),
   .bus_addr(minion_bus_addr),

   //
   .bus_read(minion_bus_read[LEDS_READ]),
   .bus_write(core_lsu_wdata)
   );

  uart my_uart
     (
      // Clock and Reset
      .clk(msoc_clk),
      .rst(!rstn),

      //I/O wires to pins
      .uart_tx(uart_tx),
      .uart_rx(uart_rx),

      //bus SFR enable
      .bus_re(minion_bus_re[UART_CE]),
      .bus_we(minion_bus_we[UART_WE]),
      .bus_addr(minion_bus_addr),

      //
      .bus_read(minion_bus_read[UART_READ]),
      .bus_write(minion_bus_write)

      );

 clk_wiz_arty_0 my_clk_wiz
 (// Clock in ports
  .clk_in1(clk_in1),
  // Clock out ports
  .msoc_clk(msoc_clk)
 );

ila_arty_0 my_ila
(
.clk (msoc_clk),

.probe0(core_instr_req),
.probe1(core_instr_gnt),
.probe2(core_instr_rvalid),
.probe3(core_instr_addr),
.probe4(core_instr_rdata),
.probe5(rstn),
.probe6(core_lsu_addr[23:20]),
.probe7(u_trans),
.probe8(u_tx_byte),
.probe9(uart_tx),
.probe10(u_baud),
.probe11(core_lsu_wdata),
.probe12(core_lsu_req&core_lsu_we&one_hot_data_addr[2]),
.probe13(core_lsu_addr[5:2])
);

endmodule // chip_top
`default_nettype wire
