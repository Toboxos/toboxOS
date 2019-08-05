ASM=nasm
CC=gcc
LD=ld

INCLUDE_DIRS= -I. -I./libc/include

CFLAGS= -m32 -c -ffreestanding -Wall -fno-builtin -fno-plt -fno-pic -nostdinc -fno-stack-protector $(INCLUDE_DIRS)
LFLAGS= -melf_i386 -T "kernel/kernel.ld"
ASFLAGS= -f elf32

KERNEL_C_SRCS=$(shell find ./kernel -name "*.c")
KERNEL_ASM_SRCS=$(shell find ./kernel -name "*.asm")

KERNEL_OBJS=$(subst .c,.co,$(KERNEL_C_SRCS))
KERNEL_OBJS+=$(subst .asm,.asmo,$(KERNEL_ASM_SRCS))

.PHONY: bootloader kernel

boot: bootloader kernel
	cat bootloader.bin kernel.bin > boot.img

bootloader: bootloader/boot.asm bootloader/gdt.asm
	$(ASM) -f bin $< -o bootloader.bin

kernel: $(KERNEL_OBJS) static/libc.a
	$(LD) $(LFLAGS) $^ -o kernel.bin
	

# Libraries 
LIBC_SRCS=$(shell find ./libc -name "*.c")
LIBC_OBJS=$(subst .c,.co,$(LIBC_SRCS))
libc: $(LIBC_OBJS)
	ar rcs static/libc.a $^

LUA_OBJS=lua/lauxlib.co
lua: $(LUA_OBJS)
	ar rcs lua/lua.a $^

# Compiling Rules
%.co: %.c
	$(CC) $(CFLAGS) $^ -o $@

%.asmo: %.asm
	$(ASM) $(ASFLAGS) $^ -o $@

clean:
	rm -f $(KERNEL_OBJS)
	rm -f $(LIBC_OBJS)
	rm -f $(LUA_OBJS)
