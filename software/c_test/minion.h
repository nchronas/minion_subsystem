#ifndef MINION_H
#define MINION_H

#define UART_TX_IDLE     0
#define UART_TX_TRANSMIT 1

int init(int temp);

void delay();

void led_output(char val);

int uart_transmit_status();

unsigned int uart_status();

void uart_transmit_byte(char c);

void uart_transmit(char *c, int len);

unsigned long int uart_receive_byte(char *c);

void uart_set_buad(int c);

#endif
