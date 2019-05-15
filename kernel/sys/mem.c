#include "mem.h"

void memcpy(void* dest, void* src, uint32_t size) {
	char* cdest = (char*) dest;
	char* csrc = (char*) src;

	for( uint32_t i = 0; i < size; ++i ) {
		*(cdest++) = *(csrc++);
	}
}

void memset(void* dest, uint8_t value, uint32_t size) {
	char* cdest = (char*) dest;
	
	for( uint32_t i = 0; i < size; ++i ) {
		*(cdest++) = value;
	}
}
