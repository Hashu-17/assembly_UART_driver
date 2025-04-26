.syntax unified
.cpu cortex-m4
.thumb

.global UART_Init
.global UART_SendByte

.equ RCC_BASE,     0x40021000
.equ RCC_AHB2ENR,  RCC_BASE + 0x4C
.equ RCC_APB1ENR1, RCC_BASE + 0x58

.equ GPIOA_BASE,   0x48000000
.equ GPIOA_MODER,  GPIOA_BASE + 0x00
.equ GPIOA_AFRL,   GPIOA_BASE + 0x20

.equ USART2_BASE,  0x40004400
.equ USART2_CR1,   USART2_BASE + 0x00
.equ USART2_BRR,   USART2_BASE + 0x0C
.equ USART2_ISR,   USART2_BASE + 0x1C
.equ USART2_TDR,   USART2_BASE + 0x28

UART_Init:
    /* Enable GPIOA and USART2 clocks */
    LDR R0, =RCC_AHB2ENR
    LDR R1, [R0]
    ORR R1, R1, #(1 << 0)       /* GPIOAEN */
    STR R1, [R0]

    LDR R0, =RCC_APB1ENR1
    LDR R1, [R0]
    ORR R1, R1, #(1 << 17)      /* USART2EN */
    STR R1, [R0]

    /* Set PA2 (TX) to Alternate Function mode */
    LDR R0, =GPIOA_MODER
    LDR R1, [R0]
    BIC R1, R1, #(0x3 << (2 * 2))   /* Clear MODER2 */
    ORR R1, R1, #(0x2 << (2 * 2))   /* Set MODER2 = 10 (AF) */
    STR R1, [R0]

    /* Set AF7 (USART2) for PA2 */
    LDR R0, =GPIOA_AFRL
    LDR R1, [R0]
    BIC R1, R1, #(0xF << (4 * 2))
    ORR R1, R1, #(0x7 << (4 * 2))
    STR R1, [R0]

    /* Configure USART2: 115200 baud (assuming 16 MHz) */
    LDR R0, =USART2_BRR
    LDR R1, =139  /* BRR = 16000000 / 115200 ≈ 139 */
    STR R1, [R0]

    /* Enable USART2, transmitter */
    LDR R0, =USART2_CR1
    LDR R1, =0x00000008 | 0x00000001  /* TE | UE */
    STR R1, [R0]

    BX LR

UART_SendByte:
    /* Input: R0 = byte to send */
    LDR R1, =USART2_ISR
.wait_tx:
    LDR R2, [R1]
    TST R2, #(1 << 7)  /* TXE bit */
    BEQ .wait_tx

    LDR R1, =USART2_TDR
    STR R0, [R1]
    BX LR
