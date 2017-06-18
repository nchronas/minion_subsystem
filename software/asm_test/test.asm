
.text

.org 0x7c

_init:
    nop

    lui x1, 0x100    # ram adress
    lui x2, 0x200    # uart adress
    lui x3, 0x300    # uart is tx? address
    lui x4, 0x700    # led adress

    addi x5, x0, 13  # num of chars
    addi x6, x0, 0   # delay counter
    addi x7, x0, 1   # led counter
    addi x8, x0, 0   # temp

_print_str:

    lw x8, mem1(x3)    # get uart availability
    andi x8, x8, 0x400 # get is_trans flag
    bne x8, x0, _print_str

    lb x8, str(x1)   # get ascii char from array
    sw x8, mem(x2)   # Tx byte

    addi x1, x1, 1   # next char
    addi x5, x5, -1  # decrease char counter

    bne x5, x0, _print_str

_loop:
    addi x7, x7, 1   # increase led counter

    sw x7, mem(x4)   # led byte
    lui x6, 0x262    # delay init

_delay:
    addi x6, x6, -1  # --
    bne x6, x0, _delay

    j _loop

.data 0x100000

            .align 3
      str:  .ascii "Hello minion\n"
      mem: .long 0
