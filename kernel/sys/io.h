#ifndef KERNEL_IO_H
#define KERNEL_IO_H

#include "../types.h"

extern void outb(uint16_t port, uint8_t byte);
extern unsigned char inb(uint16_t port);

#endif
