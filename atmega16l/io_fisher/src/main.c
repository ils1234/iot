/*
 * io_fisher.c
 *
 * Created: 2019/8/2 21:02:24
 * Author : ils
 */ 
#include "macro.h"
#include <avr/wdt.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include "global.h"
#include "uart.h"

//键盘队列
const byte key_queue[KEY_QUEUE_SIZE] = {0x70, 0xb0, 0xd0, 0xe0};
volatile byte key_play_offset = 0;
volatile byte key_during = 0;
volatile byte key_isr = KEY_ISR_IDLE;
//led队列
volatile byte led_queue[LED_QUEUE_SIZE];
volatile byte led_play_offset = 1;
//接收状态
volatile byte uart_recv_sub = CMD_IDLE;
volatile byte uart_recv_data = 0;
volatile byte uart_buffer = 0;
volatile byte uart_recv_total = 0;
volatile byte uart_recv_total_last = 0;
//红外状态
volatile byte bit_count = 0;
volatile byte data_ready = 0;
volatile byte arr[32];
//传感状态
volatile byte water_last = 0;
volatile byte radio_last = 0;
//过滤状态, 过滤器需要连接在 PORTA 0, 高电平开启，低电平关闭，依赖PORTB 6状态传感器
volatile byte filter_status = FILTER_GOOD;
volatile byte filter_work = 0;
volatile byte filter_wait = 0;

int main(void)
{
	//关中断，避免启动被打扰
	cli();
	//上电默认闪灯
	led_queue[0] = 2;
	led_queue[1] = 0xaa;
	led_queue[2] = 0x55;
	//端口连接、设定、初始化
	//A0-A7 out，继电器，低通
	DDRA = 0xff;
	PORTA = 0xff;
	//B0-B7 输入
	DDRB=0X00;
	PORTB=0x00;
    water_last = PINB;
	//C0-C7 out，指示灯，高通
	DDRC=0xff;
	PORTC=0x00;
	//D0-rxd,D1-txd,D2-D3 键盘输入/键盘中断, D4-D7-键盘扫描输出
	DDRD=0xf0;
	PORTD=0x00;
	//外部中断启用 INT0 INT1
	MCUCR=0x0a; //INT0 INT1都是下降沿中断
	MCUCSR=0; //INT2 下降沿中断
	GIFR=0xe0;
	GICR=KEY_INT_ENABLED; //启用INT0 INT1 INT2
	//设定串口
	UBRRH=0x00;
	UBRRL=0x03; //7.3728M，u2x=0，115200
	UCSRA=0x00;
	UCSRC=0x86;//写ucsrc，数据8位
	UCSRB=0x98;//使能接收中断,发送,接收
	//设置定时器T0: 按键计时器
	TCCR0 = 0x0D; //T0 CTC, 1024分频
	OCR0 = 0x90; //T0 比较计数144，为0.02秒。
	//设置定时器T1: 灯光扫描计时器
	TCCR1A = 0;
	TCCR1B = 0x0D; //T1 CTC1, 1024分频
	OCR1A = DEFAULT_OCR1A;  //T1 比较计数A=7200，为1秒。数据可在运行时被串口改变
	//设置定时器T2: 红外计时器
	TCCR2 = 0x07; //T2 普通,1024分频
    //T0比较中断 T1比较中断开启，T2不使用中断
	TIMSK = 0x12;
	//开启看门狗
	wdt_enable(WDTO_2S);
	//开中断，开始工作
	sei();
    //while做消息回复
	while(1)
	{
        byte device_h = 0;
        byte device_l = 0;
        byte key = 0;
        byte okey = 0;
begin:
		//喂狗
		wdt_reset();

        //传感器状态检测发送
        key = PINB & 0xe0;
        if (water_last != key) {
            water_last = key;
            uart_send_water();
        }
		key = PINB & 0x1b;
		if (radio_last != key) {
			radio_last = key;
			switch(key) {
				case 0x10:
					uart_send_radio(1);
					break;
				case 0x08:
					uart_send_radio(2);
					break;
				case 0x02:
					uart_send_radio(3);
					break;
				case 0x01:
					uart_send_radio(4);
					break;
				default:
					break;
			}
		}
        //红外状态检测发送
        if (data_ready == IR_READY) {
			for (byte i = 0; i<32;i++) {
				int during = arr[i];
				if (during > IR_LOW_MIN && during < IR_LOW_MAX) {
					arr[i] = 0;
				}
				else if (during > IR_HIGH_MIN && during < IR_HIGH_MAX) {
					arr[i] = 0x80;
				}
				else {
					data_ready = IR_NOT_READY;
					goto begin;
				}
			}
			for (byte i = 0; i<8;i++) {
				device_h=device_h>>1|(byte)(arr[i]);
			}
			for (byte i = 8; i<16; i++) {
				device_l=device_l>>1|(byte)(arr[i]);
			}
			for (byte i = 16; i<24; i++) {
				key=key>>1|(byte)(arr[i]);
			}
			for (byte i = 24; i<32; i++) {
				okey=okey>>1|(byte)(arr[i]);
			}
			if ((key|okey) == 0xff) {
				uart_send_ir(device_h, device_l, key);
			}
			data_ready = IR_NOT_READY;
		}
	}
}

//串口接收中断
ISR(USART_RXC_vect)
{
	byte value = UDR;
	uart_recv_total = uart_recv_total + 1;
	//not in process
	if (uart_recv_sub == CMD_IDLE) {
		switch(value) {
			case CMD_READ_RELAY:
				uart_send_relay();
				return;
			case CMD_READ_LEVEL:
				uart_send_water();
				return;
			case CMD_READ_OCR1A:
				uart_send_freq();
				return;
			case CMD_READ_LED_QUEUE:
				uart_send_queue(led_queue);
				//reply_command = value;
				return;
			case CMD_WRITE_RELAY:
			case CMD_WRITE_OCR1A:
			case CMD_WRITE_LED_QUEUE:
				uart_recv_sub = value;
				return;
			default:
				//ignore undefined cmd
				uart_recv_sub = CMD_IDLE;
				return;
		}
	}
	else { //in process
		switch(uart_recv_sub) {
			case CMD_WRITE_RELAY:
				PORTA = value;
				uart_recv_sub = CMD_IDLE;
				//reply_command = CMD_WRITE_RELAY;
				return;
			case CMD_WRITE_OCR1A:
				uart_buffer = value;
				uart_recv_sub = CMD_WRITE_OCR1AL;
				return;
			case CMD_WRITE_OCR1AL:
				OCR1AH = uart_buffer;
				OCR1AL = value;
				uart_recv_sub = CMD_IDLE;
				//reply_command = CMD_WRITE_OCR1A;
				return;
			case CMD_WRITE_LED_QUEUE:
				uart_recv_sub = CMD_WRITE_LED_QUEUE_DATA;
				uart_buffer = (value > MAX_LED_QUEUE ? MAX_LED_QUEUE : value);
				uart_recv_data = 1;
				return;
			case CMD_WRITE_LED_QUEUE_DATA:
				led_queue[uart_recv_data] = value;
				uart_recv_data = uart_recv_data + 1;
				if (uart_recv_data > uart_buffer) {
					led_queue[0] = uart_buffer;
					uart_recv_sub = CMD_IDLE;
					//reply_command = CMD_WRITE_LED_QUEUE;
				}
				return;
			default:
				uart_recv_sub = CMD_IDLE;
				return;
		}
	}
}

//灯光扫描中断
//过滤修复
ISR(TIMER1_COMPA_vect)
{
	//更新 LED 在 PORTC
	led_play_offset = led_play_offset + 1;
	if(led_play_offset > led_queue[0]) {
		led_play_offset = 1;
	}
	PORTC = led_queue[led_play_offset];
	
	//检测过滤器, PINB 6
	if(filter_status == FILTER_GOOD) {
		if ((PINB & 0x20) == 0) {
			//停机并进入修复状态
			filter_status = FILTER_DRY;
			filter_wait = FILTER_FIX_WAIT;
			filter_work = 0;
			PORTA = (PINA & 0xfe);
		}
	}
	else {
		if(filter_wait > 0) {
			PORTA = (PINA & 0xfe);
			filter_wait = filter_wait-1;
		}
		else {
			if (filter_work == 0) {
				filter_work = FILTER_FIX_WORK;
			}
		}
		if(filter_work > 0) {
			PORTA = (PINA | 0x01);
			filter_work = filter_work-1;
			if(filter_work == 0) {
				//测试是否修复，已修复则退出修复状态，否则进入下一个修复周期
				if((PINB & 0x20) != 0) {
					filter_status = FILTER_GOOD;
				}
				else {
					filter_wait = FILTER_FIX_WAIT;
				}
			}
		}
	}
}

//按键计时中断
//未按键时扫描，按键时计时
ISR(TIMER0_COMP_vect)
{
	uart_recv_total_last = uart_recv_total;
	//扫描并等侯中断修改key_value
	if (key_isr == KEY_ISR_IDLE) {
		key_play_offset = key_play_offset + 1;
		if (key_play_offset >= KEY_QUEUE_SIZE) {
			key_play_offset = 0;
			//顺便清除uart接收
			if (uart_recv_total == uart_recv_total_last) {
				uart_recv_sub = CMD_IDLE;
			}
		}
		PORTD = key_queue[key_play_offset];
		return;
	}
	//key_isr不为0时，不再扫描，对当前的INT0/INT1状态计时
	byte value = PIND & 0x0c;
	if (value != 0x0c) {
		if (key_during < MAX_BYTE) {
			key_during = key_during + 1;
		}
		return;
	}
	//value都释放后，判断上一个按键状态发送编码，然后清空key_isr并开启中断
	if (key_during > SHORT_PRESS) {
		//大于短按时间发送
		value = key_play_offset * 2 + key_isr;
		if (key_during > LONG_PRESS) {
			uart_send_key(KEY_LONG + value);
		}
		else {
			uart_send_key(KEY_SHORT + value);
		}
	}
	key_isr = KEY_ISR_IDLE;
	GICR = KEY_INT_ENABLED;
	return;
}

//按键中断1组，1357键
ISR(INT0_vect)
{
	GICR = KEY_INT_DISABLED;
	key_isr = KEY_ISR_INT0;
	key_during = 0;
	return;
}

//按键中断2组，2468键
ISR(INT1_vect)
{
	GICR = KEY_INT_DISABLED;
	key_isr = KEY_ISR_INT1;
	key_during = 0;
	return;
}

//红外中断
ISR(INT2_vect)
{
	byte during = TCNT2;
    TCNT2 = 0;
	    
	if (during>IR_START_MIN && during < IR_START_MAX) {
	    bit_count = 0;
	    data_ready = IR_NOT_READY;
	}
	else if (bit_count != MAX_BYTE) {
	    arr[bit_count++] = during;
	    if (bit_count == 32) {
		    data_ready = IR_READY;
			bit_count = 0;
	    }
	}
}
