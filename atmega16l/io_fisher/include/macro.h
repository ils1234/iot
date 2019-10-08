/*
 * macro.h
 *
 * Created: 2018/1/21 13:39:57
 *  Author: ils
 */ 


#ifndef MACRO_H_
#define MACRO_H_

#undef F_CPU
#define F_CPU 7372800UL

#define DEFAULT_OCR1A 7200
#define MAX_LED_QUEUE 100
#define LED_QUEUE_SIZE 101
#define MAX_BYTE 255
#define LONG_PRESS 80
#define SHORT_PRESS 4
#define KEY_LONG 0x60
#define KEY_SHORT 0x50
#define KEY_QUEUE_SIZE 4

#define CMD_IDLE 0
#define CMD_READ_RELAY 0x0b
#define CMD_READ_LEVEL 0x0c
#define CMD_WRITE_RELAY 0x10
#define CMD_READ_OCR1A 0x15
#define CMD_WRITE_OCR1A 0x1a
#define CMD_READ_LED_QUEUE 0x1f
#define CMD_WRITE_LED_QUEUE 0x24
//inner use only
#define CMD_WRITE_OCR1AL 0x1b
#define CMD_WRITE_LED_QUEUE_DATA 0x25
#define CMD_SEND_IR 0x50

#define KEY_INT_ENABLED 0xe0
#define KEY_INT_DISABLED 0x20

#define KEY_ISR_IDLE 0
#define KEY_ISR_INT0 1
#define KEY_ISR_INT1 2

//low 1.12ms
#define IR_LOW_MIN 6
#define IR_LOW_MAX 10
//high 2.245ms
#define IR_HIGH_MIN 14
#define IR_HIGH_MAX 18
//start 13.5ms
#define IR_START_MIN 95
#define IR_START_MAX 100

#define IR_NOT_READY 0
#define IR_READY 1

#define FILTER_FIX_WORK 10
#define FILTER_FIX_WAIT 20
#define FILTER_DRY 1
#define FILTER_GOOD 0

#endif /* MACRO_H_ */