/*
 * macro.h
 *
 * Created: 2018/1/21 13:39:57
 *  Author: ils
 */ 


#ifndef MACRO_H_
#define MACRO_H_

#define F_CPU_73728
//#define F_CPU_4M
#undef F_CPU

#define HIGH 1
#define LOW 0

#define INFLOW 0
#define READY 1
#define PROCESSED 2

#define DEVICE_ADDR_H 0
#define DEVICE_ADDR_L 1
#define KEY_ADDR 2
#define INIT_ADDR 3

#define INNER_CTRL_H 0x04
#define INNER_CTRL_L 0xfb
#define INNER_KEY 0x72

//for 7.3728M
#ifdef F_CPU_73728
#define F_CPU 7372800UL
#define UBRRL_SET 0x2f //9600, u2x=0
#define TCCR1B_SET 0x03 //64Ô¤·ÖÆµ
//low 1.12ms
#define LOW_MIN 117
#define LOW_MAX 141
//high 2.245ms
#define HIGH_MIN 247
#define HIGH_MAX 270
//start 13.5ms
#define START_MIN 1543
#define START_MAX 1567
//repeat 11.25ms
#define REPEAT_MIN 1284
#define REPEAT_MAX 1308
//repeat nop 98.75ms
#define REPEAT_WAIT_MIN 11364
#define REPEAT_WAIT_MAX 11387
//end max 51.66ms
#define END_MAX 12672
#endif

//for 4M
#ifdef F_CPU_4M
#define F_CPU 4000000UL
#define UBRRL_SET 0x19  //9600, u2x=0
#define TCCR1B_SET 0x02 //8Ô¤·ÖÆµ
//low 1.12ms
#define LOW_MIN 510
#define LOW_MAX 610
//high 2.245ms
#define HIGH_MIN 1072
#define HIGH_MAX 1173
//start 13.5ms
#define START_MIN 6700
#define START_MAX 6800
//repeat 11.25ms
#define REPEAT_MIN 5575
#define REPEAT_MAX 5675
//repeat nop 98.75ms
#define REPEAT_WAIT_MIN 49325
#define REPEAT_WAIT_MAX 49425
//end max 51.66ms
#define END_MAX 55000
#endif

#endif /* MACRO_H_ */