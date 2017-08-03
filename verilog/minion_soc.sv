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
 output reg [7:0]  to_led,
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

 input wire [3:0] btn,

 input  logic       finj_fault,
 input  logic [9:0] finj_index

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
 // finj from buttons
 //-------------------------

//wire       finj_fault;
//wire [9:0] finj_index;
// wire [3:0] dbtn;
//
// debouncer psb1_2(
//   .clk(msoc_clk),
//   .I0(btn[0]),
//   .I1(btn[1]),
//   .O0(dbtn[0]),
//   .O1(dbtn[1])
// );
//
// debouncer psb3_4(
//   .clk(msoc_clk),
//   .I0(btn[2]),
//   .I1(btn[3]),
//   .O0(dbtn[2]),
//   .O1(dbtn[3])
// );
//
// sw_state psb2(
//   .clk(msoc_clk),
//   .in(dbtn[0]),
//   .out(finj_index[0])
// );
//
// sw_state psb3(
//   .clk(msoc_clk),
//   .in(dbtn[1]),
//   .out(finj_index[1])
// );
//
// sw_state psb4(
//   .clk(msoc_clk),
//   .in(dbtn[2]),
//   .out(finj_index[2])
// );
//
// sw_state psb1(
//   .clk(msoc_clk),
//   .in(dbtn[3]),
//   .out(finj_index[3])
// );
//
assign finj_fault = (finj_index != 0);

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

always_comb
  begin:onehot
     integer i;
     core_lsu_rdata = 32'b0;
     for (i = 0; i < 16; i++)
       begin
	  one_hot_data_addr[i] = core_lsu_addr[23:20] == i;
	  core_lsu_rdata |= (one_hot_data_addr[i] ? one_hot_rdata[i] : 32'b0);
       end
  end

riscv_core_cls
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

  .ext_perf_counters_i (  2'b0         ),
  .finj_fault(finj_fault),
  .finj_index(finj_index)
);

//----------------------------------------------------------------------------//
// Data RAM
//----------------------------------------------------------------------------//

coremem coremem_d
(
 .clk_i(msoc_clk),
 .rst_ni(rstn),
 .data_req_i(core_lsu_req),
 .data_gnt_o(core_lsu_gnt),
 .data_rvalid_o(core_lsu_rvalid),
 .data_we_i(core_lsu_we),
 .CE(ce_d),
 .WE(we_d)
 );

datamem block_d (
  .clk(msoc_clk),
  .wea(ce_d & one_hot_data_addr[1] & we_d),
  .ena(we_d ? core_lsu_be : 4'b1111),
  .addra(core_lsu_addr[15:2]),
  .dina(core_lsu_wdata),
  .douta(one_hot_rdata[1]),
  .web(1'b0),
  .enb(4'b0000),
  .addrb(core_lsu_addr[15:2]),
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
    .web(ce_d & one_hot_data_addr[0] & we_d),
    .enb(we_d ? core_lsu_be : 4'b1111),
    .addrb(core_lsu_addr[15:2]),
    .dinb(core_lsu_wdata),
    .doutb(one_hot_rdata[0])
   );

  //////////////////////////////////////////////////////////////////
  ///                                                            ///
  /// APB Slave 0: APB UART interface                            ///
  ///                                                            ///
  //////////////////////////////////////////////////////////////////

reg u_trans;
reg u_recv;
reg [15:0] u_baud;
wire received, recv_err, is_recv, is_trans, uart_maj;
wire uart_almostfull, uart_full, uart_rderr, uart_wrerr, uart_empty;
wire [11:0] uart_wrcount, uart_rdcount;
wire [8:0] uart_fifo_data_out;
reg  [7:0] u_tx_byte;

rx_delay uart_rx_dly(
.clk(msoc_clk),
.in(uart_rx),
.maj(uart_maj));

uart i_uart(
    .clk(msoc_clk), // The master clock for this module
    .rst(~rstn), // Synchronous reset.
    .rx(uart_maj), // Incoming serial line
    .tx(uart_tx), // Outgoing serial line
    .transmit(u_trans), // Signal to transmit
    .tx_byte(u_tx_byte), // Byte to transmit
    .received(received), // Indicated that a byte has been received.
    .rx_byte(core_lsu_rx_byte), // Byte received
    .is_receiving(is_recv), // Low when receive line is idle.
    .is_transmitting(is_trans), // Low when transmit line is idle.
    .recv_error(recv_err), // Indicates error in receiving packet.
    .baud(u_baud),
    .recv_ack(u_recv)
    );

assign one_hot_rdata[3] = {uart_wrcount,uart_almostfull,uart_full,uart_rderr,uart_wrerr,uart_fifo_data_out[8],is_trans,is_recv,~uart_empty,uart_fifo_data_out[7:0]};

   wire    tx_rd_fifo;
   wire    rx_wr_fifo;

always @(posedge msoc_clk or negedge rstn)
  if (!rstn)
    begin
	u_recv <= 0;
	core_lsu_addr_dly <= 0;
	to_led <= 0;
	u_baud <= 16'd651;
	u_trans <= 1'b0;
	u_tx_byte <= 8'b0;
	  end
   else
     begin
  u_recv <= received;
	core_lsu_addr_dly <= core_lsu_addr;
	if (core_lsu_req&core_lsu_we&one_hot_data_addr[7])
    begin
	    to_led <= core_lsu_wdata;
      $display("Tx byte %x\n", core_lsu_wdata[7:0]);
    end
  u_trans <= 1'b0;
    if (core_lsu_req&core_lsu_we&one_hot_data_addr[2])
      case(core_lsu_addr[5:2])
        0: begin
             u_trans <= 1'b1;
             u_tx_byte <= core_lsu_wdata[7:0];
             $display("Tx byte %c\n", core_lsu_wdata[7:0]);
           end
        1: u_baud <= core_lsu_wdata;
      endcase
     end


my_fifo #(.width(9)) uart_rx_fifo (
  .rd_clk(~msoc_clk),      // input wire read clk
  .wr_clk(~msoc_clk),      // input wire write clk
  .rst(~rstn),      // input wire rst
  .din({recv_err,core_lsu_rx_byte}),      // input wire [width-1 : 0] din
  .wr_en(received&&!u_recv),  // input wire wr_en
  .rd_en(core_lsu_req&core_lsu_we&one_hot_data_addr[3]),  // input wire rd_en
  .dout(uart_fifo_data_out),    // output wire [width-1 : 0] dout
  .rdcount(uart_rdcount),         // 12-bit output: Read count
  .rderr(uart_rderr),             // 1-bit output: Read error
  .wrcount(uart_wrcount),         // 12-bit output: Write count
  .wrerr(uart_wrerr),             // 1-bit output: Write error
  .almostfull(uart_almostfull),   // output wire almost full
  .full(uart_full),    // output wire full
  .empty(uart_empty)  // output wire empty
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
