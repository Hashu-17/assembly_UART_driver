/* startup.s - Cortex-M4 startup code for STM32L433RCT */

.syntax unified
.cpu cortex-m4
.thumb

/* External symbols from linker script */
.extern main
.extern _sidata  /* start of initialized data in flash */
.extern _sdata   /* start of data section in RAM */
.extern _edata   /* end of data section in RAM */
.extern _sbss    /* start of bss section */
.extern _ebss    /* end of bss section */

/* Stack top defined here */
.section .isr_vector, "a", %progbits
.type g_pfnVectors, %object
.size g_pfnVectors, .-g_pfnVectors

g_pfnVectors:
  .word _estack              /* Initial stack pointer */
  .word Reset_Handler        /* Reset handler */
  .word Default_Handler      /* NMI */
  .word Default_Handler      /* Hard Fault */
  .word Default_Handler      /* MemManage */
  .word Default_Handler      /* BusFault */
  .word Default_Handler      /* UsageFault */
  .word 0                    /* Reserved */
  .word 0                    /* Reserved */
  .word 0                    /* Reserved */
  .word 0                    /* Reserved */
  .word Default_Handler      /* SVCall */
  .word Default_Handler      /* Debug monitor */
  .word 0                    /* Reserved */
  .word Default_Handler      /* PendSV */
  .word Default_Handler      /* SysTick */

  /* You can extend with IRQ handlers here if needed */

.section .text.Reset_Handler
.global Reset_Handler
.type Reset_Handler, %function

Reset_Handler:
  /* Copy .data section from flash to RAM */
  ldr r0, =_sidata
  ldr r1, =_sdata
  ldr r2, =_edata
.copy_data:
  cmp r1, r2
  ittt lt
  ldrlt r3, [r0], #4
  strlt r3, [r1], #4
  blt .copy_data

  /* Zero .bss section */
  ldr r0, =_sbss
  ldr r1, =_ebss
  movs r2, #0
.zero_bss:
  cmp r0, r1
  it lt
  strlt r2, [r0], #4
  blt .zero_bss

  /* Call main() */
  bl main

.infinite_loop:
  b .infinite_loop

/* Default handler for unused IRQs */
.type Default_Handler, %function
Default_Handler:
  b .
  
/* End of startup */