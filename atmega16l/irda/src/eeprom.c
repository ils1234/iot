/*
 * eeprom.c
 *
 * Created: 2018/1/28 21:08:22
 *  Author: ils
 */ 
#include "eeprom.h"

void ee_write(unsigned int addr, byte data) {
	while (EECR & (1<<EEWE));
	EEAR = addr;
	EEDR = data;
	EECR |= (1<<EEMWE);
	EECR |= (1<<EEWE);
}

byte ee_read(unsigned int addr) {
	while (EECR & (1<<EEWE)) ;
	EEAR = addr;
	EECR |= (1<<EERE);
	return EEDR;
}