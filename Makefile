ASM=nasm
CC=gcc
LD=ld

CFLAGS= -m32 -c -ffreestanding -Wall -fno-builtin -fno-plt -fno-pic -nostdinc -fno-stack-protector 
LFLAGS= -melf_i386 -T "kernel/kernel.ld"

.PHONY: bootloader kernel

os: bootloader kernel
	cat bootloader.bin kernel.bin > boot

bootloader: bootloader/boot.asm bootloader/gdt.asm
	$(ASM) -f bin $< -o bootloader.bin

kernel: kernel/kernel_main.o kernel/screen/screen.o
	$(LD) $(LFLAGS) $^ -o kernel.bin

%.o: %.c
	$(CC) $(CFLAGS) $^ -o $@

clean:
	rm kernel/kernel_main.o
