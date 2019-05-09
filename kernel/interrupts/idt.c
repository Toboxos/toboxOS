#include "../types.h"

typedef struct {
	uint64_t limit	: 16;
	uint64_t ptr	: 32;
	uint64_t unused : 16;
} IDTR;

typedef struct {
	uint64_t offset_1	: 16;
	uint64_t selector	: 16;
	uint64_t zero		: 8;
	uint64_t type		: 8;
	uint64_t offset_2	: 16;
} IDT_Entry;


IDTR idtr;
IDT_Entry idt[256];

extern void load_idt();
extern void standard_isr_entry();

void init_idt() {
	idtr.limit = (256 * 8) - 1; // number of entries * 8 bytes - 1
	idtr.ptr = (uint32_t) &idt;

	setCursor(0, 3);
	printhex(&standard_isr_entry);

	for( int i = 0; i < 256; ++i) {
		idt[i].selector 	= (uint16_t) 0x08;	// Kernel code selector
		idt[i].zero 		= (uint8_t)  0x00;
		idt[i].type 		= (uint8_t)  0x8E; // 1000 1110
		idt[i].offset_1 	= (uint16_t) ((int) standard_isr_entry & 0xFFFF);
		idt[i].offset_2 	= (uint16_t) ((int) standard_isr_entry >>  16);
	}

	load_idt();
}	
