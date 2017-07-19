
`include "riscv_config.sv"

//import riscv_defines::*;

module riscv_core_cls
#(
  parameter N_EXT_PERF_COUNTERS = 0,
  parameter INSTR_RDATA_WIDTH   = 32
)
(
  // Clock and Reset
  input  logic        clk_i,
  input  logic        rst_ni,

  input  logic        clock_en_i,    // enable clock, otherwise it is gated
  input  logic        test_en_i,     // enable all clock gates for testing

  // Core ID, Cluster ID and boot address are considered more or less static
  input  logic [31:0] boot_addr_i,
  input  logic [ 3:0] core_id_i,
  input  logic [ 5:0] cluster_id_i,

  // Instruction memory interface
  output logic                         instr_req_o,
  input  logic                         instr_gnt_i,
  input  logic                         instr_rvalid_i,
  output logic                  [31:0] instr_addr_o,
  input  logic [INSTR_RDATA_WIDTH-1:0] instr_rdata_i,

  // Data memory interface
  output logic        data_req_o,
  input  logic        data_gnt_i,
  input  logic        data_rvalid_i,
  output logic        data_we_o,
  output logic [3:0]  data_be_o,
  output logic [31:0] data_addr_o,
  output logic [31:0] data_wdata_o,
  input  logic [31:0] data_rdata_i,
  input  logic        data_err_i,

  // Interrupt inputs
  input  logic [31:0] irq_i,                 // level sensitive IR lines

  // Debug Interface
  input  logic        debug_req_i,
  output logic        debug_gnt_o,
  output logic        debug_rvalid_o,
  input  logic [14:0] debug_addr_i,
  input  logic        debug_we_i,
  input  logic [31:0] debug_wdata_i,
  output logic [31:0] debug_rdata_o,
  output logic        debug_halted_o,
  input  logic        debug_halt_i,
  input  logic        debug_resume_i,

  // CPU Control Signals
  input  logic        fetch_enable_i,
  output logic        core_busy_o,

  input  logic [N_EXT_PERF_COUNTERS-1:0] ext_perf_counters_i,

  input  logic       finj_fault,
  input  logic [9:0] finj_index
);

//Core slave 1
// Instruction memory interface
wire        instr_req_o_cls1;
wire [31:0] instr_addr_o_cls1;

// Data memory interface
wire        data_req_o_cls1;
logic       data_we_o_cls1;
wire [3:0]  data_be_o_cls1;
wire [31:0] data_addr_o_cls1;
wire [31:0] data_wdata_o_cls1;

// CPU Control Signals
wire        core_busy_o_cls1;

//Core slave 2
// Instruction memory interface
wire        instr_req_o_cls2;
wire [31:0] instr_addr_o_cls2;

// Data memory interface
wire        data_req_o_cls2;
logic       data_we_o_cls2;
wire [3:0]  data_be_o_cls2;
wire [31:0] data_addr_o_cls2;
wire [31:0] data_wdata_o_cls2;

// CPU Control Signals
wire        core_busy_o_cls2;

riscv_core
#(
  .N_EXT_PERF_COUNTERS ( 0 )
)
RISCV_CORE_master
(
  .clk_i           ( clk_i             ),
  .rst_ni          ( rst_ni            ),

  .clock_en_i      ( clock_en_i        ),
  .test_en_i       ( test_en_i         ),

  .boot_addr_i     ( boot_addr_i       ),
  .core_id_i       ( 4'h0              ),
  .cluster_id_i    ( 6'h0              ),

  .instr_addr_o    ( instr_addr_o      ),
  .instr_req_o     ( instr_req_o       ),
  .instr_rdata_i   ( instr_rdata_i     ),
  .instr_gnt_i     ( instr_gnt_i       ),
  .instr_rvalid_i  ( instr_rvalid_i    ),

  .data_addr_o     ( data_addr_o       ),
  .data_wdata_o    ( data_wdata_o      ),
  .data_we_o       ( data_we_o         ),
  .data_req_o      ( data_req_o        ),
  .data_be_o       ( data_be_o         ),
  .data_rdata_i    ( data_rdata_i      ),
  .data_gnt_i      ( data_gnt_i        ),
  .data_rvalid_i   ( data_rvalid_i     ),
  .data_err_i      ( data_err_i        ),

  .irq_i           ( irq_i             ),

  .debug_req_i     ( debug_req_i       ),
  .debug_gnt_o     ( debug_gnt_o       ),
  .debug_rvalid_o  ( debug_rvalid_o    ),
  .debug_addr_i    ( debug_addr_i      ),
  .debug_we_i      ( debug_we_i        ),
  .debug_wdata_i   ( debug_wdata_i     ),
  .debug_rdata_o   ( debug_rdata_o     ),
  .debug_halted_o  ( debug_halted_o    ),
  .debug_halt_i    ( debug_halt_i      ),
  .debug_resume_i  ( debug_resume_i    ),

  .fetch_enable_i  ( fetch_enable_i    ),
  .core_busy_o     ( core_busy_o       ),

  .ext_perf_counters_i ( ext_perf_counters_i )
);

riscv_core
#(
  .N_EXT_PERF_COUNTERS ( 0 )
)
RISCV_CORE_slave_1
(
  .clk_i           ( clk_i             ),
  .rst_ni          ( rst_ni            ),

  .clock_en_i      ( clock_en_i        ),
  .test_en_i       ( test_en_i         ),

  .boot_addr_i     ( boot_addr_i       ),
  .core_id_i       ( 4'h1              ),
  .cluster_id_i    ( 6'h0              ),

  .instr_addr_o    ( instr_addr_o_cls1 ),
  .instr_req_o     ( instr_req_o_cls1  ),
  .instr_rdata_i   ( instr_rdata_i     ),
  .instr_gnt_i     ( instr_gnt_i       ),
  .instr_rvalid_i  ( instr_rvalid_i    ),

  .data_addr_o     ( data_addr_o_cls1  ),
  .data_wdata_o    ( data_wdata_o_cls1 ),
  .data_we_o       ( data_we_o_cls1    ),
  .data_req_o      ( data_req_o_cls1   ),
  .data_be_o       ( data_be_o_cls1    ),
  .data_rdata_i    ( data_rdata_i      ),
  .data_gnt_i      ( data_gnt_i        ),
  .data_rvalid_i   ( data_rvalid_i     ),
  .data_err_i      ( data_err_i        ),

  .irq_i           ( irq_i             ),

  .debug_req_i     (        ),
  .debug_gnt_o     (   ),
  .debug_rvalid_o  (  ),
  .debug_addr_i    (       ),
  .debug_we_i      (         ),
  .debug_wdata_i   (      ),
  .debug_rdata_o   (   ),
  .debug_halted_o  (  ),
  .debug_halt_i    (       ),
  .debug_resume_i  (     ),

  .fetch_enable_i  ( fetch_enable_i    ),
  .core_busy_o     ( core_busy_o_cls1  ),

  .ext_perf_counters_i ( ext_perf_counters_i )
);

riscv_core
#(
  .N_EXT_PERF_COUNTERS ( 0 )
)
RISCV_CORE_slave_2
(
  .clk_i           ( clk_i             ),
  .rst_ni          ( rst_ni            ),

  .clock_en_i      ( clock_en_i        ),
  .test_en_i       ( test_en_i         ),

  .boot_addr_i     ( boot_addr_i       ),
  .core_id_i       ( 4'h1              ),
  .cluster_id_i    ( 6'h0              ),

  .instr_addr_o    ( instr_addr_o_cls2 ),
  .instr_req_o     ( instr_req_o_cls2  ),
  .instr_rdata_i   ( instr_rdata_i     ),
  .instr_gnt_i     ( instr_gnt_i       ),
  .instr_rvalid_i  ( instr_rvalid_i    ),

  .data_addr_o     ( data_addr_o_cls2  ),
  .data_wdata_o    ( data_wdata_o_cls2 ),
  .data_we_o       ( data_we_o_cls2    ),
  .data_req_o      ( data_req_o_cls2   ),
  .data_be_o       ( data_be_o_cls2    ),
  .data_rdata_i    ( data_rdata_i      ),
  .data_gnt_i      ( data_gnt_i        ),
  .data_rvalid_i   ( data_rvalid_i     ),
  .data_err_i      ( data_err_i        ),

  .irq_i           ( irq_i             ),

  .debug_req_i     (        ),
  .debug_gnt_o     (   ),
  .debug_rvalid_o  (  ),
  .debug_addr_i    (       ),
  .debug_we_i      (         ),
  .debug_wdata_i   (      ),
  .debug_rdata_o   (   ),
  .debug_halted_o  (  ),
  .debug_halt_i    (       ),
  .debug_resume_i  (     ),

  .fetch_enable_i  ( fetch_enable_i    ),
  .core_busy_o     ( core_busy_o_cls2  ),

  .ext_perf_counters_i ( ext_perf_counters_i )
);

//------------------------------------------------------------------------------
//
// fault injection unit
//
//------------------------------------------------------------------------------

//wire       finj_fault;
//wire [7:0] finj_index;

always_comb begin
  case(finj_index[4:0])
    1: begin
        instr_req_o_cls1 ^= finj_fault;
        $display("Tx byte %c\n", finj_index[4:0]);
       end
    2: begin
        instr_addr_o_cls1 ^= finj_fault << finj_index[9:5];
        $display("Tx byte %c\n", finj_index[4:0]);
       end
    3: begin
        data_req_o_cls1 ^= finj_fault;
        $display("Tx byte %c\n", finj_index[4:0]);
       end
    4: begin
        data_we_o_cls1 ^= finj_fault;
        $display("Tx byte %c\n", finj_index[4:0]);
       end
    5: begin
        data_be_o_cls1 ^= finj_fault << finj_index[9:5];
        $display("Tx byte %c\n", finj_index[4:0]);
      end
    6: begin
        data_addr_o_cls1 ^= finj_fault << finj_index[9:5];
        $display("Tx byte %c\n", finj_index[4:0]);
      end
    7: begin
        data_wdata_o_cls1 ^= finj_fault << finj_index[9:5];
        $display("Tx byte %c\n", finj_index[4:0]);
      end
    8: begin
       instr_req_o_cls2 ^= finj_fault;
       $display("Tx byte %c\n", finj_index[4:0]);
      end
    9: begin
       instr_addr_o_cls2 ^= finj_fault << finj_index[9:5];
       $display("Tx byte %c\n", finj_index[4:0]);
      end
    10: begin
       data_req_o_cls2 ^= finj_fault;
       $display("Tx byte %c\n", finj_index[4:0]);
      end
    11: begin
       data_we_o_cls2 ^= finj_fault;
       $display("Tx byte %c\n", finj_index[4:0]);
      end
    12: begin
       data_be_o_cls2 ^= finj_fault << finj_index[9:5];
       $display("Tx byte %c\n", finj_index[4:0]);
      end
    13: begin
       data_addr_o_cls2 ^= finj_fault << finj_index[9:5];
       $display("Tx byte %c\n", finj_index[4:0]);
      end
    14: begin
       data_wdata_o_cls2 ^= finj_fault << finj_index[9:5];
       $display("Tx byte %c\n", finj_index[4:0]);
      end
  endcase
end

//pseudo_random_gen cls_random_finj (
//  .clk(clk_i),
//  .rst(rst_ni),

//  .fault(finj_fault),
//  .index(finj_index)
//);

//------------------------------------------------------------------------------

cls_cmp_unit cls_assist (
  .clk(clk_i),
  .rst(rst_ni),

  .fault(),

  .instr_req_ms(instr_req_o),
  .instr_addr_ms(instr_addr_o),

  .data_req_ms(data_req_o),
  .data_we_ms(data_we_o),
  .data_be_ms(data_be_o),
  .data_addr_ms(data_addr_o),
  .data_wdata_ms(data_wdata_o),
  .core_busy_ms(core_busy_o),

  .instr_req_sl1(instr_req_o_cls1),
  .instr_addr_sl1(instr_addr_o_cls1),

  .data_req_sl1(data_req_o_cls1),
  .data_we_sl1(data_we_o_cls1),
  .data_be_sl1(data_be_o_cls1),
  .data_addr_sl1(data_addr_o_cls1),
  .data_wdata_sl1(data_wdata_o_cls1),
  .core_busy_sl1(core_busy_o_cls1),

  .instr_req_sl2(instr_req_o_cls2),
  .instr_addr_sl2(instr_addr_o_cls2),

  .data_req_sl2(data_req_o_cls2),
  .data_we_sl2(data_we_o_cls2),
  .data_be_sl2(data_be_o_cls2),
  .data_addr_sl2(data_addr_o_cls2),
  .data_wdata_sl2(data_wdata_o_cls2),
  .core_busy_sl2(core_busy_o_cls2)
);

//cls_handler_unit {
//    .clk( clk ),
//    .res_i( res ),

//    .res_o( rst_ni ),

//    .fault ()
//};

endmodule
