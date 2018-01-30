/*
 * uart.c
 *
 * Created: 2018/1/21 13:32:52
 *  Author: ils
 */ 
#include "uart.h"
#include <avr/wdt.h>
#include <avr/io.h>
#include "global.h"
//数据发送
void uart_transmit(const unsigned char i) {
	// 等待发送缓冲器为空
	while(!(UCSRA&(1<<UDRE)));
	UDR=i; // 发送数据
}

void uart_send(const char * x) {
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
}

//数据接收
unsigned char uart_receive(void) {
	if (!(UCSRA&(1<<RXC))) {
		// 等待接收数据
		return 0;
	}
	return UDR; // 获取数据
}

void uart_recv(char * buffer, int size) {
	byte i = 0;
	byte t = 1;
	byte tt = 1;
	byte v;
	while(i < size) {
		v = uart_receive();
		wdt_reset();
		if (v !=0) {
			buffer[i++] = v;
			continue;
		}
		t++;
		if (t==255) {
			tt++;
			if (tt==255) {
				i=0;
				t=1;
				tt=1;
			}
		}
	}
}
