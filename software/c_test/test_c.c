#include "minion.h"
#include "stdio.h"

int temp[20] = { 10 } ;

int main() {

  init(temp[0]);

  uart_set_buad(651);

  char str[] = "Hello minion\n";
  uart_transmit(str, 13);

  // cutecomm
  uart_transmit(str, 3);

  char i = 0;
  char inc_char;
  unsigned long int status;
  while(1) {
    i++;
    led_output(i);
    delay();
    //status = uart_receive_byte(&inc_char);
    //if(status > 0xFFFFF) {
    //  inc_char++;
    //  uart_transmit_byte('Y');
    //}

    status = uart_receive_byte(&inc_char);
    str[0] = status;
    str[1] = status >> 8;
    str[2] = status >> 16;
    str[3] = status >> 24;
    str[4] = '\n';
    str[5] = '\n';
    str[6] = '\n';
    str[7] = '\n';
    uart_transmit(str, 8);
  }
}
