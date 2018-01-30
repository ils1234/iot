/*
 * utils.c
 *
 * Created: 2018/1/21 13:41:59
 *  Author: ils
 */ 
#include "utils.h"
#include <avr/io.h>
#include "macro.h"

byte toggle_relay() {
	if ((PINA&0x01) != 0) {
		PORTA = LOW;
		return HIGH;
	}
	PORTA = HIGH;
	return LOW;
}

void set_relay(byte status) {
	if (status == 0) {
		PORTA = HIGH;
	}
	else {
		PORTA = LOW;
	}
}

byte get_relay() {
	if ((PINA&0x01) != 0) {
		return LOW;
	}
	return HIGH;
}