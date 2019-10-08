/*
 * uart.c
 *
 * Created: 2019/10/03 15:19:00
 *  Author: ils
 */ 
#include "uart.h"
#include <avr/wdt.h>
#include <avr/io.h>
//数据发送
void uart_transmit(const byte i) {
	// 等待发送缓冲器为空
	while(!(UCSRA&(1<<UDRE)));
	UDR=i; // 发送数据
}

void uart_send_head(const byte * x) {
	byte i = 0;
	unsigned char v;
	
	while(1) {
		v = * (x + i);
		if (v != 0) {
			uart_transmit(v);
		}
		else {
			break;
		}
		i++;
	}
	uart_transmit('(');
	uart_transmit('\'');
}

void uart_send_end() {
	uart_transmit('\'');
	uart_transmit(')');
	uart_transmit('\r');
	uart_transmit('\n');
}

void uart_send_byte(const byte v) {
	byte x = (v & 0xf0) >> 4;
	if (x>=0 && x<=9) {
		uart_transmit(x+48);
	}
	else {
		uart_transmit(x+87);
	}
	
	x= v&0x0f;
	if (x>=0 && x<=9) {
		uart_transmit(x+48);
	}
	else {
		uart_transmit(x+87);
	}
}

void uart_send_relay() {
	uart_send_head("am_relay");
	uart_send_byte(PINA);
	uart_send_end();
}

void uart_send_water() {
	byte x = PINB;
	uart_send_head("am_water");
	if ((x & 0x80) != 0) {
		uart_transmit('h');
	}
	else {
		uart_transmit('l');
	}
	if ((x & 0x40) != 0) {
		uart_transmit('h');
	}
	else {
		uart_transmit('l');
	}
	if ((x & 0x20) != 0) {
		uart_transmit('h');
	}
	else {
		uart_transmit('l');
	}
	uart_send_end();
}

void uart_send_freq() {
	uart_send_head("am_freq");
	uart_send_byte(OCR1AH);
	uart_send_byte(OCR1AL);
	uart_send_end();
}

void uart_send_queue(const byte * x) {
	byte len = x[0];
	uart_send_head("am_queue");
	for (byte i=1; i<=len; i=i+1) {
		uart_send_byte(x[i]);
	}
	uart_send_end();
}

void uart_send_key(const byte value) {
	uart_send_head("am_key");
	uart_send_byte(value);
	uart_send_end();
}

void uart_send_ir(const byte dev_h, const byte dev_l, const byte key) {
	uart_send_head("am_ir");
	uart_send_byte(dev_h);
	uart_send_byte(dev_l);
	uart_send_byte(key);
	uart_send_end();
}
