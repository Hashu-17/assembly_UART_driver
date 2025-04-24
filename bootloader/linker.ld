 /* linker.ld - Bare-metal linker script for STM32L433RCT6
 * Flash size: 256KB
 * RAM size:   64KB (SRAM1 + SRAM2)
 */

ENTRY(Reset_Handler)

MEMORY
{
  FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 256K
  RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 64K
}

SECTIONS
{
  /* Code and read-only data */
  .text :
  {
    KEEP(*(.isr_vector))         /* Interrupt vectors */
    *(.text*)                    /* Code */
    *(.rodata*)                  /* Read-only data */
    KEEP(*(.init)) KEEP(*(.fini))
  } > FLASH

  /* Initialized data in RAM, load from FLASH */
  .data : AT(ADDR(.text) + SIZEOF(.text))
  {
    _sdata = .;
    *(.data*)
    _edata = .;
  } > RAM

  /* Zero-initialized data */
  .bss :
  {
    _sbss = .;
    *(.bss*)
    *(COMMON)
    _ebss = .;
  } > RAM

  /* Stack pointer is set manually in startup.s, so we don't need a .stack section */

  /* Symbols for startup code */
  _sidata = LOADADDR(.data);
}