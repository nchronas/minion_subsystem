riscv32-unknown-elf-as -march=IXpulpv2 test.asm
riscv32-unknown-elf-objdump -d a.out

riscv32-unknown-elf-objcopy -R .debug_frame -R .comment -R .stack -R .heapsram -R .heapscm -R .scmlock -R .rodata -R .eh_frame -R .shbss -R .data -R .bss -O binary --gap-fill=0 a.out a.bin
riscv32-unknown-elf-objcopy -j .rodata -j .data -O binary --gap-fill=0 a.out a.dat
riscv32-unknown-elf-objcopy -I binary -O verilog a.bin code.mem0
riscv32-unknown-elf-objcopy -I binary -O verilog a.dat data.mem0
../../romgen/bigromtest code.mem0 data.mem0 code.v data.v code.mem1 data.mem1
