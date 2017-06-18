#ifndef MINION_H
#define MINION_H

#define UART_TX_IDLE     0
#define UART_TX_TRANSMIT 1

//void delay_ms(int sleep);

void led_output(char val);

int uart_transmit_status();

void uart_transmit_byte(char c);

void uart_transmit(char *c, int len);

#endif
