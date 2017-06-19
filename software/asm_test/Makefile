
O =  test.asm

all: clean target.elf

target.elf: $O
	riscv32-unknown-elf-as -march=IXpulpv2 -o $@ $O
	riscv32-unknown-elf-size target.elf | tee target.size
	riscv32-unknown-elf-nm target.elf >target.nm
	riscv32-unknown-elf-objdump -d target.elf >target.dis
	riscv32-unknown-elf-readelf -S target.elf >target.sections
	riscv32-unknown-elf-objcopy -R .debug_frame -R .comment -R .stack -R .heapsram -R .heapscm -R .scmlock -R .rodata -R .eh_frame -R .shbss -R .data -R .bss -O binary --gap-fill=0 target.elf target.bin
	riscv32-unknown-elf-objcopy -j .rodata -j .data -O binary --gap-fill=0 target.elf target.dat
	riscv32-unknown-elf-objcopy -I binary -O verilog target.bin code.mem0
	riscv32-unknown-elf-objcopy -I binary -O verilog target.dat data.mem0
	riscv32-unknown-elf-objcopy --srec-len 1 --output-target=srec target.elf target.s19
	../../romgen/bigromtest code.mem0 data.mem0 code.v data.v code.mem1 data.mem1

clean:
	rm -f target.* code.* data.*
