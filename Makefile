ASM=nasm
CC=gcc
LD=ld

CFLAGS= -m32 -c -ffreestanding -Wall -fno-builtin -fno-plt -fno-pic -nostdinc -fno-stack-protector 
LFLAGS= -melf_i386 -T "kernel/kernel.ld"
ASFLAGS= -f elf32

KERNEL_C_SRCS=$(shell find ./kernel -name "*.c")
KERNEL_ASM_SRCS=$(shell find ./kernel -name "*.asm")

KERNEL_OBJS=$(subst .c,.co,$(KERNEL_C_SRCS))
KERNEL_OBJS+=$(subst .asm,.asmo,$(KERNEL_ASM_SRCS))

.PHONY: bootloader kernel

os: bootloader kernel
	cat bootloader.bin kernel.bin > boot

bootloader: bootloader/boot.asm bootloader/gdt.asm
	$(ASM) -f bin $< -o bootloader.bin

kernel: $(KERNEL_OBJS) 
	$(LD) $(LFLAGS) $^ -o kernel.bin

%.co: %.c
	$(CC) $(CFLAGS) $^ -o $@

%.asmo: %.asm
	$(ASM) $(ASFLAGS) $^ -o $@

clean:
	rm $(KERNEL_OBJS)
