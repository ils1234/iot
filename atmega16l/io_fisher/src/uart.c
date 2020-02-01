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
inline void uart_transmit(const byte i) {
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

inline void uart_send_end() {
	uart_transmit('\'');
	uart_transmit(')');
	uart_transmit('\r');
	uart_transmit('\n');
}

inline void uart_send_half_byte(const byte v) {
	byte x= v&0x0f;
	if (x>=0 && x<=9) {
		uart_transmit(x+48);
	}
	else {
		uart_transmit(x+87);
	}
}

inline void uart_send_byte(const byte v) {
	uart_send_half_byte(v >> 4);
	uart_send_half_byte(v);
}

inline void uart_send_relay() {
	uart_send_head("am_relay");
	uart_send_byte(PINA);
	uart_send_end();
}

inline void uart_send_water() {
	uart_send_head("am_water");
	uart_send_half_byte(PINB >> 5);
	uart_send_end();
}

inline void uart_send_radio(const byte v) {
	uart_send_head("am_radio");
	uart_send_half_byte(v);
	uart_send_end();
}

inline void uart_send_freq() {
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

inline void uart_send_key(const byte value) {
	uart_send_head("am_key");
	uart_send_byte(value);
	uart_send_end();
}

inline void uart_send_ir(const byte dev_h, const byte dev_l, const byte key) {
	uart_send_head("am_ir");
	uart_send_byte(dev_h);
	uart_send_byte(dev_l);
	uart_send_byte(key);
	uart_send_end();
}
