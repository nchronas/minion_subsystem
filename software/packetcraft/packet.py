import serial
import array
import time
import threading
import sys
import os
import curses

stdscr = curses.initscr()
stdscr.clear()
stdscr.refresh()
#port = serial.Serial("/dev/tty.usbserial", baudrate=9600, timeout=1.0)

rx_pkt_counter = 0
tx_pkt_counter = 0

time.sleep(1)

#                              start    TC   APP   SEQ   PKT ACK   SER   SER   CRC  stop
#                               flag          ID  flag   LEN      type  subT        flag
test_packet = array.array('B', [0x7E, 0x18, 0x01, 0xC0, 0x3C,  0, 0x11, 0x01, 0xFB, 0x7F]).tostring()

#            start    TM   APP   SEQ   PKT ACK   SER   SER   CRC  stop
#             flag          ID  flag   LEN      type  subT        flag
cmp_packet = [0x7E, 0x08, 0x02, 0xC0, 0x3C,  0, 0x11, 0x02, 0xFB, 0x7F]

def write_to_port():
    global port, tx_pkt_counter
    time.sleep(2)
    while True:
        port.write(test_packet)
        tx_pkt_counter += 1
        time.sleep(0.1)

def read_from_port():
    global port, rx_pkt_counter
    buffer = ""
    while True:
        rcv = port.read(5)
        if len(rcv) > 0:
            buffer += rcv
            find_packet(buf)

def write_to_port_test():
    global tx_pkt_counter
    time.sleep(2)
    while True:
        tx_pkt_counter += 1
        time.sleep(0.3)

def read_from_port_test():
    global rx_pkt_counter
    while True:
        rx_pkt_counter += 1
        time.sleep(0.45)

def find_packet(buf):
    start = 0
    for i, c in enumerate(buf):
        if c == 0x7E:
            start = i
        elif c == 0x7F:
            if start != 0:
                check_packet(buf[start:i])
            buf = buf[i:]
            find_packet(buf)

def check_packet(buf):
    global rx_pkt_counter
    rx_pkt_counter += 1

def update_menu():
    global rx_pkt_counter, tx_pkt_counter
    global stdscr

    height = 5; width = 40
    win = curses.newwin(height, width, begin_y, begin_x)
    curses.init_pair(1, curses.COLOR_RED, curses.COLOR_WHITE)
    while True:
        win.addstr(0,0, "RED ALERT! " + str(rx_pkt_counter), curses.color_pair(1))
        win.addstr(10,0, "RED ALERT!" + str(tx_pkt_counter), curses.color_pair(1))
        win.addstr(20,0, "RED ALERT!" + str(tx_pkt_counter - x_pkt_counter), curses.color_pair(1))
        time.sleep(0.1)

def reset(screen):
    curses.nocbreak()
    screen.keypad(0)
    curses.echo()
    curses.endwin()

def testing():
    thread_rx  = threading.Thread(target=read_from_port)
    thread_tx  = threading.Thread(target=write_from_port)
    thread_pkt = threading.Thread(target=write_from_port)

    thread_rx.start()
    thread_tx.start()

    try:
        update_menu()
    except KeyboardInterrupt:
        reset(screen)
        port.close()
        exit()
