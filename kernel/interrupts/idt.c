#include "../types.h"
#include "../screen/screen.h"

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

extern void irq01_entry();

void init_idt() {
	idtr.limit = (256 * 8) - 1; // number of entries * 8 bytes - 1
	idtr.ptr = (uint32_t) &idt;

	for( int i = 0; i < 256; ++i) {
		setEntry(i, 0x8E, standard_isr_entry);
	}

	setEntry(9, 0x8E, irq01_entry);


	load_idt();
}

void setEntry(int index, uint8_t type, uint32_t address) {
	idt[index].selector 	= (uint16_t) 0x08;	// Kernel code selector
	idt[index].zero 		= (uint8_t)  0x00;
	idt[index].type 		= type; // 1000 1110
	idt[index].offset_1 	= (uint16_t) ((int) address & 0xFFFF);
	idt[index].offset_2 	= (uint16_t) ((int) address >>  16);
}	
