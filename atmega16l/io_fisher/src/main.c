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

//���̶���
const byte key_queue[KEY_QUEUE_SIZE] = {0x70, 0xb0, 0xd0, 0xe0};
volatile byte key_play_offset = 0;
volatile byte key_during = 0;
volatile byte key_isr = KEY_ISR_IDLE;
//led����
volatile byte led_queue[LED_QUEUE_SIZE];
volatile byte led_play_offset = 1;
//����״̬
volatile byte uart_recv_sub = CMD_IDLE;
volatile byte uart_recv_data = 0;
volatile byte uart_buffer = 0;
volatile byte uart_recv_total = 0;
volatile byte uart_recv_total_last = 0;
//����״̬
volatile byte bit_count = 0;
volatile byte data_ready = 0;
volatile byte arr[32];
//����״̬
volatile byte water_last = 0;
volatile byte radio_last = 0;
//����״̬, ��������Ҫ������ PORTA 0, �ߵ�ƽ�������͵�ƽ�رգ�����PORTB 6״̬������
volatile byte filter_status = FILTER_GOOD;
volatile byte filter_work = 0;
volatile byte filter_wait = 0;

int main(void)
{
	//���жϣ���������������
	cli();
	//�ϵ�Ĭ������
	led_queue[0] = 2;
	led_queue[1] = 0xaa;
	led_queue[2] = 0x55;
	//�˿����ӡ��趨����ʼ��
	//A0-A7 out���̵�������ͨ
	DDRA = 0xff;
	PORTA = 0xff;
	//B0-B7 ����
	DDRB=0X00;
	PORTB=0x00;
    water_last = PINB;
	//C0-C7 out��ָʾ�ƣ���ͨ
	DDRC=0xff;
	PORTC=0x00;
	//D0-rxd,D1-txd,D2-D3 ��������/�����ж�, D4-D7-����ɨ�����
	DDRD=0xf0;
	PORTD=0x00;
	//�ⲿ�ж����� INT0 INT1
	MCUCR=0x0a; //INT0 INT1�����½����ж�
	MCUCSR=0; //INT2 �½����ж�
	GIFR=0xe0;
	GICR=KEY_INT_ENABLED; //����INT0 INT1 INT2
	//�趨����
	UBRRH=0x00;
	UBRRL=0x03; //7.3728M��u2x=0��115200
	UCSRA=0x00;
	UCSRC=0x86;//дucsrc������8λ
	UCSRB=0x98;//ʹ�ܽ����ж�,����,����
	//���ö�ʱ��T0: ������ʱ��
	TCCR0 = 0x0D; //T0 CTC, 1024��Ƶ
	OCR0 = 0x90; //T0 �Ƚϼ���144��Ϊ0.02�롣
	//���ö�ʱ��T1: �ƹ�ɨ���ʱ��
	TCCR1A = 0;
	TCCR1B = 0x0D; //T1 CTC1, 1024��Ƶ
	OCR1A = DEFAULT_OCR1A;  //T1 �Ƚϼ���A=7200��Ϊ1�롣���ݿ�������ʱ�����ڸı�
	//���ö�ʱ��T2: �����ʱ��
	TCCR2 = 0x07; //T2 ��ͨ,1024��Ƶ
    //T0�Ƚ��ж� T1�Ƚ��жϿ�����T2��ʹ���ж�
	TIMSK = 0x12;
	//�������Ź�
	wdt_enable(WDTO_2S);
	//���жϣ���ʼ����
	sei();
    //while����Ϣ�ظ�
	while(1)
	{
        byte device_h = 0;
        byte device_l = 0;
        byte key = 0;
        byte okey = 0;
begin:
		//ι��
		wdt_reset();

        //������״̬��ⷢ��
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
        //����״̬��ⷢ��
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

//���ڽ����ж�
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

//�ƹ�ɨ���ж�
//�����޸�
ISR(TIMER1_COMPA_vect)
{
	//���� LED �� PORTC
	led_play_offset = led_play_offset + 1;
	if(led_play_offset > led_queue[0]) {
		led_play_offset = 1;
	}
	PORTC = led_queue[led_play_offset];
	
	//��������, PINB 6
	if(filter_status == FILTER_GOOD) {
		if ((PINB & 0x20) == 0) {
			//ͣ���������޸�״̬
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
				//�����Ƿ��޸������޸����˳��޸�״̬�����������һ���޸�����
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

//������ʱ�ж�
//δ����ʱɨ�裬����ʱ��ʱ
ISR(TIMER0_COMP_vect)
{
	uart_recv_total_last = uart_recv_total;
	//ɨ�貢�Ⱥ��ж��޸�key_value
	if (key_isr == KEY_ISR_IDLE) {
		key_play_offset = key_play_offset + 1;
		if (key_play_offset >= KEY_QUEUE_SIZE) {
			key_play_offset = 0;
			//˳�����uart����
			if (uart_recv_total == uart_recv_total_last) {
				uart_recv_sub = CMD_IDLE;
			}
		}
		PORTD = key_queue[key_play_offset];
		return;
	}
	//key_isr��Ϊ0ʱ������ɨ�裬�Ե�ǰ��INT0/INT1״̬��ʱ
	byte value = PIND & 0x0c;
	if (value != 0x0c) {
		if (key_during < MAX_BYTE) {
			key_during = key_during + 1;
		}
		return;
	}
	//value���ͷź��ж���һ������״̬���ͱ��룬Ȼ�����key_isr�������ж�
	if (key_during > SHORT_PRESS) {
		//���ڶ̰�ʱ�䷢��
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

//�����ж�1�飬1357��
ISR(INT0_vect)
{
	GICR = KEY_INT_DISABLED;
	key_isr = KEY_ISR_INT0;
	key_during = 0;
	return;
}

//�����ж�2�飬2468��
ISR(INT1_vect)
{
	GICR = KEY_INT_DISABLED;
	key_isr = KEY_ISR_INT1;
	key_during = 0;
	return;
}

//�����ж�
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
