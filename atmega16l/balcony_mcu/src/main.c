#include "macro.h"
#include <avr/wdt.h>
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "uart.h"
#include "utils.h"
#include "global.h"

int main(void)
{
	//var def
	char serial_data[7];
	byte port_id;
	//关中断，避免启动被打扰
	cli();
	//端口连接、设定、初始化
	//A0-A7 out
	DDRA = 0xFF;
	PORTA = 0xFF;
	//B0-B7 disable
	DDRB=0X00;
	PORTB=0x00;
	//C0-C6 disable, C7-in
	DDRC=0x00;
	PORTC=0x00;
	//D0-rxd,D1-txd,D2-D6 disable, D7-led
	DDRD=0x80;
	PORTD=0x00;
	//MCUCR=0x03;
	//GICR=0x40;
	//开启看门狗
	wdt_enable(WDTO_2S);
	//设定串口
	UBRRH=0x00;
	//UBRRL=0x19;//4M, u2x=0
	UBRRL=0x2F; //7.3728M, u2x=0
	UCSRA=0x00;
	UCSRC=0x86;//写ucsrc，数据8位
	UCSRB=0x18;//使能发送,接收
	//开启micro计时
	serial_data[6]=0;
	//开中断，开始工作
	sei();
	while(1)
	{
		wdt_reset();
		uart_recv(serial_data, 6);
		wdt_reset();
		if (PIND&0x80) {
			PORTD = 0;
		}
		else {
			PORTD = 0x80;
		}
		if (serial_data[0] != serial_data[2]
			|| serial_data[0] != serial_data[4]
			|| serial_data[1] != serial_data[3]
			|| serial_data[1] != serial_data[5]) {
				uart_send("bad data\n");
				continue;
			}
		port_id = serial_data[0] - 48;
		if (port_id == 8) {
			if ((PINC&0x80) != 0) {
				uart_send("on");
			}
			else {
				uart_send("off");
			}
			continue;
		}
		if (port_id > 7) {
			print_value();
			continue;
		}
		switch (serial_data[1]) {
			case '0':
				PORTA = PINA|(1<<port_id);
				uart_send("off");
				break;
			case '1':
				PORTA = PINA&(~(1<<port_id));
				uart_send("on");
				break;
			case '2':
			    if ((PINA&(1<<port_id)) != 0) {
					uart_send("off");
				}
				else {
					uart_send("on");
				}
				break;
			default:
			    uart_send("error");
				break;
		}
		wdt_reset();
	}
}
