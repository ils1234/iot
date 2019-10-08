#include "macro.h"
#include <avr/wdt.h>
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <avr/eeprom.h>
#include "uart.h"
#include "utils.h"
#include "global.h"

volatile byte bit_count;
volatile byte data_ready;
volatile byte data_repeat;
int arr[34];

int main(void)
{
	//���жϣ���������������
	cli();
	//�˿����ӡ��趨����ʼ��
	//A0 �����, A1-A7 ���룬�ر�����
	DDRA = 0x01;
	PORTA = 0x01;
	//B0-B7 ͣ�ã��ر�����
	DDRB=0X00;
	PORTB=0x00;
	//C0-C7 ͣ�ã��ر�����
	DDRC=0x00;
	PORTC=0x00;
	//D0-rxd, D1-txd,D2-int0����, D3-int1��ť, D4-D7 disable
	DDRD=0x80;
	PORTD=0x0c; //D2 D3����
	//MCUCR=0x03;
	//GICR=0x40;
	//�趨����
	UBRRH=0x00;
	UBRRL=UBRRL_SET; //0x2f for 7.3728M, u2x=0, 0x19 for 4M, u2x=0
	UCSRA=0x00;
	UCSRC=0x86;//дucsrc������8λ
	UCSRB=0x18;//ʹ�ܷ���,����
	//�����ж�
	MCUCR=0x0a; //int 0��1����Ϊ�½��ش���
	GICR=0xc0; //ʹ��int0 int1����ֹint2
	GIFR=0xe0; //����жϱ�־
	//���ö�ʱ��
	TCCR1A = 0;
	TCCR1B = TCCR1B_SET; //Ԥ��Ƶ
	OCR1A = END_MAX;
	TIMSK = 0x10;
	//��ʼ������
	bit_count = 200;
	data_ready = 0;
	//��ȡEEPROM
	byte ctrl_device_h = 0;
	byte ctrl_device_l = 0xbf;
	byte ctrl_key = 0x15;

	//�������Ź�
	wdt_enable(WDTO_2S);
	//���жϣ���ʼ����
	sei();
	//�ȴ����ݾ���
	while(1) {
begin:
		//ι��
		wdt_reset();
		if (data_ready == 1) {
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
			byte device_h = 0;
			byte device_l = 0;
			byte key = 0;
			byte okey = 0;

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
			if ((key|okey) ==255) {
				if (ctrl_device_h == device_h && ctrl_device_l == device_l && ctrl_key == key) {
                	if ((PINA&0x01) != 0) {
		                PORTA = LOW;
					}
					else {
						PORTA = HIGH;
					}					
				}
				uart_transmit(device_h);
				uart_transmit(device_l);
				uart_transmit(key);
			}
			else {
				uart_transmit(0);
				uart_transmit(device_h);
				uart_transmit(device_l);
				uart_transmit(key);
				uart_transmit(okey);
			}
			data_ready = 0;
		}
		if (data_repeat > 50) {
			uart_transmit('r');
		}
	}
}

ISR(INT0_vect)
{
    int during = TCNT1;
	TCNT1 = 0;
	
	if (during>START_MIN && during < START_MAX) {
		bit_count = 0;
		data_ready = 0;
		data_repeat = 0;
	}
	else if (during>REPEAT_MIN && during<REPEAT_MAX) {
		data_repeat++;
	}
	else {
		arr[bit_count++] = during;
		if (bit_count == 32) {
			data_ready = 1;
		}
	}
}

ISR(INT1_vect)
{
	if ((PINA&0x01) != 0) {
		PORTA = LOW;
	}
	else {
		PORTA = HIGH;
	}
    uart_transmit('B');
}

ISR(TIMER1_COMPA_vect)
{
	data_ready = 0;
	data_repeat = 0;
}
