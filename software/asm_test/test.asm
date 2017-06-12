.text
.global _start
.org 0x20
_start:
nop
addi x1, x1, 1
nop
nop
nop
addi x6, x0, 117 # 'u'
lui x7, 0x200    # uart adress
sw x6, mem1(x7)  # Tx byte
nop
nop
nop
lui x5, 0x100
sw x1, mem1(x5)
nop
lw x2, mem1(x5)
nop
lw x3, mem1(x5)
nop
addi x3, x3, 2
nop
sw x3, mem2(x5)
nop
nop
j _start

.org 0x00100000
.data
            .align 3
      mem1: .word 0
      mem2: .word 1
