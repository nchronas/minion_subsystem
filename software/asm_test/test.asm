.text

.org 0x20
_init:
addi x1, x0, 1
lui x2, 0x200    # uart adress
lui x3, 0x700    # led adress
_loop:

addi x1, x1, 1

sw x1, mem1(x2)  # Tx byte
sw x1, mem1(x3)  # led byte


j _loop

.data 0x100000

            .align 3
      mem1: .long 0
      mem2: .word 1
