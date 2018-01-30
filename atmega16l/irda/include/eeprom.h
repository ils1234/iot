/*
 * eeprom.h
 *
 * Created: 2018/1/28 21:08:07
 *  Author: ils
 */ 


#ifndef EEPROM_H_
#define EEPROM_H_

#include "global.h"
#include <avr/io.h>

void ee_write(unsigned int addr, byte data);
byte ee_read(unsigned int addr);


#endif /* EEPROM_H_ */