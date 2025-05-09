# STM32 UART Driver in Assembly (STM32L433RCT)
The goal was to write a a custom UART driver for the STM32L433RCT-P microcontroller. A custom bootloader was also written, which is nearly the same or similar to the bootloaders ive written for the other projects.


This repository contains a complete **UART transmit-only driver written in ARM assembly** for the STM32L4 series microcontroller, specifically targeting **USART2 on pin PA2**.

This guide walks through **every line** of the code to get a full understanding of what's being done at the hardware level.





## uart_driver.s

```asm
.syntax unified
.cpu cortex-m4
.thumb
````

### Explanation:

* Tells the assembler to use **unified syntax** for both ARM and Thumb.
* Targeting **Cortex-M4 CPU**.
* `.thumb` ensures the output is in **Thumb instruction set**, used by most STM32 chips.

---

```asm
.global UART_Init
.global UART_SendByte
```

### Explanation:

* Expose `UART_Init` and `UART_SendByte` functions to C files or linker.



### Define Peripheral Base Addresses and Offsets

```asm
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
```

### Explanation:

* These are **memory-mapped register addresses** from the reference manual.
* `MODER`, `AFRL`, etc. control GPIO and USART configuration.
* `BRR` is for baud rate, `CR1` for USART control, and `TDR` is transmit register.

---

## UART_Init

```asm
UART_Init:
```

Initializes USART2 TX on PA2 for 115200 baud.

---

### Step 1: Enable GPIOA and USART2 Clocks

```asm
LDR R0, =RCC_AHB2ENR
LDR R1, [R0]
ORR R1, R1, #(1 << 0)       /* GPIOAEN */
STR R1, [R0]
```

* Loads AHB2 peripheral enable register.
* Sets bit 0 → enables GPIOA clock.

```asm
LDR R0, =RCC_APB1ENR1
LDR R1, [R0]
ORR R1, R1, #(1 << 17)      /* USART2EN */
STR R1, [R0]
```

* Loads APB1ENR1 register.
* Sets bit 17 → enables USART2 peripheral clock.

---

### Step 2: Configure PA2 as Alternate Function (AF7)

```asm
LDR R0, =GPIOA_MODER
LDR R1, [R0]
BIC R1, R1, #(0x3 << (2 * 2))   /* Clear MODER2 */
ORR R1, R1, #(0x2 << (2 * 2))   /* Set MODER2 = 10 (AF) */
STR R1, [R0]
```

* Clears bits 5:4 (PA2 mode) and sets to `10` → alternate function.

```asm
LDR R0, =GPIOA_AFRL
LDR R1, [R0]
BIC R1, R1, #(0xF << (4 * 2))   /* Clear AFRL2 */
ORR R1, R1, #(0x7 << (4 * 2))   /* AF7 = USART2 */
STR R1, [R0]
```

* Sets alternate function for PA2 to AF7 (USART2).

---

### Step 3: Configure USART2

```asm
LDR R0, =USART2_BRR
LDR R1, =139  /* BRR = 16000000 / 115200 ≈ 139 */
STR R1, [R0]
```

* Configures baud rate register.
* 16 MHz / 115200 baud = \~139

---

```asm
LDR R0, =USART2_CR1
LDR R1, =0x00000008 | 0x00000001  /* TE | UE */
STR R1, [R0]
```

* Enables transmitter (`TE`) and USART (`UE`) by setting bits in `CR1`.

---

```asm
BX LR
```

* Return from function.

---

```asm
UART_SendByte:
```

Sends a byte from R0 via USART2.

---

### Step 1: Wait Until TXE is Set

```asm
LDR R1, =USART2_ISR
.wait_tx:
    LDR R2, [R1]
    TST R2, #(1 << 7)  /* TXE bit */
    BEQ .wait_tx
```

* Waits until **Transmit Data Register Empty (TXE)** is 1.

---

### Step 2: Write Byte to TDR

```asm
LDR R1, =USART2_TDR
STR R0, [R1]
BX LR
```

* Transmits the byte in R0.

---

## How to Use This Driver

1. Call `UART_Init()` once at startup
2. Use `UART_SendByte()` to send any character (ASCII or binary)
3. Works great for debug messages or basic comms

---


