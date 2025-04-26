#include <stdint.h>

// Declare the functions from uart.s
extern void UART_Init(void);
extern void UART_SendByte(uint8_t data);

// A small delay loop
static void delay(volatile uint32_t count) {
    while (count--) {
        __asm__ volatile("nop");
    }
}

int main(void) {
    UART_Init();

    const char *msg = "Hello from bare-metal UART!\r\n";

    while (1) {
        const char *p = msg;
        while (*p) {
            UART_SendByte(*p++);
        }
        delay(1000000);
    }
}
