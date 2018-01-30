#include "macro.h"
#include <avr/wdt.h>
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "uart.h"
#include "eeprom.h"
#include "utils.h"
#include "global.h"

volatile byte bit_count;
volatile byte data_ready;
volatile byte data_repeat;
volatile byte device_h = 0;
volatile byte device_l = 0;
volatile byte key = 0;
volatile byte okey = 0;
int arr[32];

int main(void)
{
	//关中断，避免启动被打扰
	cli();
	//端口连接、设定、初始化
	//A0 输出高, A1-A7 输入，关闭上拉
	DDRA = 0x01;
	PORTA = 0x01;
	//B0-B7 停用，关闭上拉
	DDRB=0X00;
	PORTB=0x00;
	//C0-C7 停用，关闭上拉
	DDRC=0x00;
	PORTC=0x00;
	//D0-rxd, D1-txd,D2-int0红外, D3-int1按钮, D4-D7 disable
	DDRD=0x80;
	PORTD=0x0c; //D2 D3上拉
	//MCUCR=0x03;
	//GICR=0x40;
	//设定串口
	UBRRH=0x00;
	UBRRL=UBRRL_SET; //0x2f for 7.3728M, u2x=0, 0x19 for 4M, u2x=0
	UCSRA=0x00;
	UCSRC=0x86;//写ucsrc，数据8位
	UCSRB=0x18;//使能发送,接收
	//设置中断
	MCUCR=0x0a; //int 0，1均设为下降沿触发
	GICR=0xc0; //使能int0 int1，禁止int2
	GIFR=0xe0; //清除中断标志
	//设置定时器
	TCCR1A = 0;
	TCCR1B = TCCR1B_SET; //预分频
	OCR1A = END_MAX;
	TIMSK = 0x10;
	//初始化变量
	bit_count = 200;
	data_ready = 0;
	data_repeat = 0;
	//读取EEPROM
	byte ctrl_device_h = ee_read(DEVICE_ADDR_H);
	byte ctrl_device_l = ee_read(DEVICE_ADDR_L);
	byte ctrl_key = ee_read(KEY_ADDR);
	byte ctrl_init = ee_read(INIT_ADDR);
	set_relay(ctrl_init);
	//开启看门狗
	wdt_enable(WDTO_2S);
	//开中断，开始工作
	sei();
	//等待数据就绪
	while(1) {
begin:
		//喂狗
		wdt_reset();
		if (data_ready == READY) {
			for (byte i = 0; i<32;i++) {
				int during = arr[i];
				if (during > LOW_MIN && during < LOW_MAX) {	
					arr[i] = 0;
				}
				else if (during > HIGH_MIN && during < HIGH_MAX) {
					arr[i] = 0x80;
				}
				else {
					data_ready = 0;
					uart_transmit('E');
					goto begin;
				}
			}
			device_h = 0;
			for (byte i = 0; i<8;i++) {
				device_h=device_h>>1|(byte)(arr[i]);
			}
			device_l = 0;
			for (byte i = 8; i<16; i++) {
				device_l=device_l>>1|(byte)(arr[i]);
			}
			key = 0;
			for (byte i = 16; i<24; i++) {
				key=key>>1|(byte)(arr[i]);
			}
			okey = 0;
			for (byte i = 24; i<32; i++) {
				okey=okey>>1|(byte)(arr[i]);
			}
			if ((key|okey) ==255) {
				if (ctrl_device_h == device_h && ctrl_device_l == device_l && ctrl_key == key) {
                	toggle_relay();	
					uart_transmit('V');
				}
				else {
					uart_transmit('X');
				}
			}
			else {
				uart_transmit('C');
			}
			data_ready = PROCESSED;
		}
		if (data_repeat > 90) {
			ctrl_device_h = device_h;
			ctrl_device_l = device_l;
			ctrl_key = key;
			uart_transmit('R');
			cli();
			ee_write(DEVICE_ADDR_H, ctrl_device_h);
			ee_write(DEVICE_ADDR_L, ctrl_device_l);
			ee_write(KEY_ADDR, ctrl_key);
			ee_write(INIT_ADDR, get_relay());
			sei();
			data_repeat = 0;			
		}
	}
}

ISR(INT0_vect)
{
    int during = TCNT1;
	TCNT1 = 0;
	
	if (during>START_MIN && during < START_MAX) {
		bit_count = 0;
		data_ready = INFLOW;
		data_repeat = 0;
	}
	else if (during>REPEAT_MIN && during<REPEAT_MAX){
		data_repeat++;
	}
	else if (data_ready == INFLOW && bit_count<32) {
   		arr[bit_count++] = during;
		if (bit_count == 32) {
			data_ready = READY;
		}
	}
}

ISR(INT1_vect)
{
	toggle_relay();
}

ISR(TIMER1_COMPA_vect)
{
	data_ready = INFLOW;
	data_repeat = 0;
	bit_count = 0;
}
