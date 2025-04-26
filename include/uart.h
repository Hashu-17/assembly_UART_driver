#ifndef UART_H
#define UART_H

#include <stdint.h>

void UART_Init(void);
void UART_SendByte(uint8_t data);

#endif
