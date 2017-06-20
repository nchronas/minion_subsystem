#include "minion.h"

#define ADD_UART_TX        0x200000
#define ADD_UART_TX_STATUS 0x300000
#define ADD_LED_OUT        0x700000

int init(int temp) {
  return temp + 1;
}

void delay() {
 long delay = 250000;
 for(long i = 0; i < delay; i++) {  }
}

void led_output(char val) {
  volatile unsigned char *led = (unsigned char *) ADD_LED_OUT;
  *led = val;
}

int uart_transmit_status() {
  volatile unsigned int *status = (unsigned int *) ADD_UART_TX_STATUS;
  if((*status & 0x400) == 0) {
    return UART_TX_IDLE;
  } else {
    return UART_TX_TRANSMIT;
  }
}

void uart_transmit_byte(char c) {
  volatile unsigned int *byte = (unsigned int *) ADD_UART_TX;
  *byte = c;
}

void uart_transmit(char *c, int len) {
  for(int i = 0; i < len; i++) {
    while(uart_transmit_status() != UART_TX_IDLE) { }
    uart_transmit_byte(c[i]);
  }
}
