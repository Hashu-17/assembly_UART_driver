# MCU and toolchain
CPU = -mcpu=cortex-m4 -mthumb
CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
LD = arm-none-eabi-ld
OBJCOPY = arm-none-eabi-objcopy
CFLAGS = $(CPU) -Wall -Wextra -nostdlib -nostartfiles -ffreestanding
LDFLAGS = $(CPU) -T linker.ld

# Source files
SRC = main.c uart.s startup.s
OBJ = $(SRC:.c=.o)
OBJ := $(OBJ:.s=.o)

# Output
TARGET = firmware

all: $(TARGET).elf $(TARGET).hex

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.s
	$(AS) $(CPU) $< -o $@

$(TARGET).elf: $(OBJ)
	$(CC) $(LDFLAGS) $^ -o $@

$(TARGET).hex: $(TARGET).elf
	$(OBJCOPY) -O ihex $< $@

clean:
	rm -f *.o *.elf *.hex

flash: $(TARGET).hex
	st-flash write $(TARGET).hex 0x8000000
