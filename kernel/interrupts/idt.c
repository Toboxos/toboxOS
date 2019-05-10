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

/* IRQ entries for Hardware interrupts */
extern void irq00_entry();
extern void irq01_entry();
extern void irq02_entry();
extern void irq03_entry();
extern void irq04_entry();
extern void irq05_entry();
extern void irq06_entry();
extern void irq07_entry();
extern void irq08_entry();
extern void irq09_entry();
extern void irq10_entry();
extern void irq11_entry();
extern void irq12_entry();
extern void irq13_entry();
extern void irq14_entry();
extern void irq15_entry();

void init_idt() {
	idtr.limit = (256 * 8) - 1; // number of entries * 8 bytes - 1
	idtr.ptr = (uint32_t) &idt;

	/* Fill all interrupts with standard isr. Indivual interrupts will set later on */
	for( int i = 0; i < 256; ++i) {
		setEntry(i, 0x8E, standard_isr_entry);
	}

	setEntry(0x08,	0x8E, 	irq00_entry);
	setEntry(0x09, 	0x8E, 	irq01_entry);
	setEntry(0x0A, 	0x8E, 	irq02_entry);
	setEntry(0x0B, 	0x8E, 	irq03_entry);
	setEntry(0x0C, 	0x8E, 	irq04_entry);
	setEntry(0x0D, 	0x8E, 	irq05_entry);
	setEntry(0x0E, 	0x8E, 	irq06_entry);
	setEntry(0x0F, 	0x8E, 	irq07_entry);
	
	setEntry(0x70, 	0x8E, 	irq08_entry);
	setEntry(0x71, 	0x8E,	irq09_entry);
	setEntry(0x72, 	0x8E, 	irq10_entry);
	setEntry(0x73, 	0x8E, 	irq11_entry);
	setEntry(0x74, 	0x8E, 	irq12_entry);
	setEntry(0x75, 	0x8E, 	irq13_entry);
	setEntry(0x76, 	0x8E, 	irq14_entry);
	setEntry(0x77, 	0x8E, 	irq15_entry);

	load_idt();
}

void setEntry(int index, uint8_t type, uint32_t address) {
	idt[index].selector 	= (uint16_t) 0x08;	// Kernel code selector
	idt[index].zero 		= (uint8_t)  0x00;
	idt[index].type 		= type; // 1000 1110
	idt[index].offset_1 	= (uint16_t) ((int) address & 0xFFFF);
	idt[index].offset_2 	= (uint16_t) ((int) address >>  16);
}	
