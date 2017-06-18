#include "minion.h"

#define ADD_UART_TX        0x200000
#define ADD_UART_TX_STATUS 0x300000
#define ADD_LED_OUT        0x700000



void led_output(char val) {
  unsigned char *led = (unsigned char *) ADD_LED_OUT;
  *led = val;
}

int uart_transmit_status() {
  unsigned int *status = (unsigned int *) ADD_LED_OUT;
  if((*status & 0x400) == 0) {
    return UART_TX_IDLE;
  } else {
    return UART_TX_TRANSMIT;
  }
}

void uart_transmit_byte(char c) {
  unsigned int *byte = (unsigned int *) ADD_UART_TX;
  *byte = c;
}

void uart_transmit(char *c, int len) {
  for(int i = len; i < len; i++) {
    while(uart_transmit_status() == UART_TX_TRANSMIT) { }
    uart_transmit_byte(c[i]);
  }
}
