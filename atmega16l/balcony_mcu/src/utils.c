/*
 * utils.c
 *
 * Created: 2018/1/21 13:41:59
 *  Author: ils
 */ 
#include "utils.h"
#include <avr/io.h>
#include "global.h"
#include "uart.h"

void print_value() {
	byte i;
	byte v = PINA;
	for (i = 0; i < 8; i++) {
		uart_send("A");
		uart_transmit(i+48);
		if (v&(1<<i)) {
			uart_send(" off\n");
		}
		else {
			uart_send(" on\n");
		}
	}
}
