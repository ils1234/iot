/*
 * uart.h
 *
 * Created: 2019/10/03 15:19:00
 *  Author: ils
 */ 


#ifndef UART_H_
#define UART_H_
#include "global.h"

extern void uart_send_relay();
extern void uart_send_water();
extern void uart_send_freq();
extern void uart_send_queue(const byte * q);
extern void uart_send_key(const byte value);
extern void uart_send_ir(const byte dev_h, const byte dev_l, const byte key);

#endif /* UART_H_ */