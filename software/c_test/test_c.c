#include "minion.h"

int temp[20] = { 10 } ;

int main() {

  init(temp[0]);

  char str[] = "Hello minion\n";
  uart_transmit(str, 13);

  char i = 0;

  while(1) {
    i++;
    led_output(i);
    delay();
  }
}
