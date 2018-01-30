/*
 * uart.h
 *
 * Created: 2018/1/21 13:32:15
 *  Author: ils
 */ 


#ifndef UART_H_
#define UART_H_

extern void uart_transmit(const unsigned char i);
extern void uart_send(const char * x);
extern unsigned char uart_receive(void);
extern void uart_recv(char * buffer, int size);

#endif /* UART_H_ */