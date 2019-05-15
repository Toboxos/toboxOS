#ifndef KERNEL_MEM_H
#define KERNEL_MEM_H

#include "../types.h"

/**
 * Copies size bytes from src to dest
 *
 * @param	dest	destination address
 * @param	src		source address
 * @param	size	how many bytes
 */
extern void memcpy(void* dest, void* src, uint32_t size);

/**
 * Sets size bytes to value at dst location
 *
 * @param	dest	location of data
 * @param	value	value of bytes data should have
 * @param	size	how many bytes
 */
extern void memset(void* dest, uint8_t value, uint32_t size);

#endif
