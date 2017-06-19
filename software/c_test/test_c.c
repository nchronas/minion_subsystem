
#include "minion.h"

char str[] = "Hello minion\n";

void delay_ms(int sleep) {
 //long delay = ((float)sleep / 0.00024);
long delay = 250000;
 for(long i = 0; i < delay; i++) {  }
}

int main() {

  uart_transmit(str, 13);

  char i = 0;

  while(1) {
    i++;
    led_output(i);
    delay_ms(500);
  }
}
