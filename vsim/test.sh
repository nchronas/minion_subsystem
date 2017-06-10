#!/bin/sh

# cleanup
rm -rf obj_dir

verilator \
  --cc \
  ../verilog/minion_soc.sv \
  ../verilog/coremem.sv \
  ../verilog/debouncer.v \
  ../verilog/dpram.v \
  ../verilog/dualmem.v \
  ../verilog/fstore2.v \
  ../verilog/my_fifo.v \
  ../verilog/rambyte.v \
  ../verilog/rx_delay.v \
  ../verilog/uart.v \
  ../pulpino/ips/riscv/include/riscv_defines.sv \
  ../pulpino/ips/riscv/controller.sv \
  ../pulpino/ips/riscv/cs_registers.sv \
  ../pulpino/ips/riscv/debug_unit.sv \
  ../pulpino/ips/riscv/decoder.sv \
  ../pulpino/ips/riscv/exc_controller.sv \
  ../pulpino/ips/riscv/ex_stage.sv \
  ../pulpino/ips/riscv/hwloop_controller.sv \
  ../pulpino/ips/riscv/hwloop_regs.sv \
  ../pulpino/ips/riscv/id_stage.sv \
  ../pulpino/ips/riscv/if_stage.sv \
  ../pulpino/ips/riscv/include/riscv_config.sv \
  ../pulpino/ips/riscv/load_store_unit.sv \
  ../pulpino/ips/riscv/mult.sv \
  ../pulpino/ips/riscv/prefetch_L0_buffer.sv \
  ../pulpino/ips/riscv/register_file_ff.sv \
  ../pulpino/ips/riscv/riscv_core.sv \
  ../pulpino/rtl/components/cluster_clock_gating.sv \
  ../pulpino/ips/riscv/alu.sv \
  ../pulpino/ips/riscv/alu_div.sv \
  ../pulpino/ips/riscv/compressed_decoder.sv \
  ../pulpino/ips/riscv/prefetch_buffer.sv \
  src/mem.v \
  -DVERILATOR_GCC \
  +incdir+../verilog \
        +incdir+../pulpino/rtl/includes \
        +incdir+../pulpino/ips/riscv/include \
  --top-module minion_soc \
  --unroll-count 256 \
  --error-limit 500 \
    --output-split 80000 \
  --output-split-cfuncs 10000 \
  -Wno-lint -Wno-style -Wno-STMTDLY -Wno-ASSIGNIN -Wno-fatal --coverage\
  -CFLAGS "-std=c++11" \
  -CFLAGS "-I/media/nanimo/lowRISC_repo/minion_subsystem/vsim" \
  -LDFLAGS "-pthread" \
  --trace \
 	--exe veri_top.cc

  #-CFLAGS "-I$(base_dir)/src/test/cxx/common -I$(base_dir)/src/test/cxx/veri \s
