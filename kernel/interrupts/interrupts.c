#include "../sys/io.h"
#include "interrupts.h"

/**
 * Holds the information about the Interrupt Descriptor Table (IDT).
 *
 * more details found in the Intel Manual
 */
typedef struct {
	uint64_t limit	: 16; /** size of table - 1 in bytes */
	uint64_t ptr	: 32; /** ptr to start of table in memory */
	uint64_t unused	: 16; /** unused. Just for alignment */
} IDTR;

/**
 * Entry of IDT
 *
 * more details found in the Intel Manual
 */
typedef struct {
	uint64_t offset_1	: 16; /** first 16 bits of isr entry relative to segment */
	uint64_t selector	: 16; /** segment selector from GDT */
	uint64_t reserved	:  5; /** seserved bits by intel */
	uint64_t zero		:  3; /** bits are zero (see Intel Manual, Volume 3, 6.11) */
	uint64_t type		:  5; /** type of entry */
	uint64_t dpl		:  2; /** descriptor privlige level */
	uint64_t present	:  1; /** segment present flag */
	uint64_t offset_2	: 16; /** last 16 bits of isr entry relative to segment */ 
} IDT_Entry;

IDTR idtr;					/** Interrupt Descriptor Table Refernce */ 
IDT_Entry idt[256] = {0};	/** Interrupt Descriptor Table */
void (*custom_isr[256])(interrupt_status status) = {0};

/* Normal Interrupt Entries */
extern void default_isr_entry();

/* IRQ Entries */
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

extern void load_idt(); /** Extern function in assembler loads the IDT */

/**
 * set the entry in the IDT to the given values
 *
 * @param	index		index of interrupt in table
 * @param	offset		offset of isr entry
 * @param	selector	segment selector in GDT
 * @param	type		type of entry
 * @param	dpl			descriptor privilige level
 */
void setEntry(uint8_t index, uint32_t offset, uint16_t selector, uint8_t type, uint8_t dpl) {
	idt[index].offset_1 = offset & 0xFFFF; 	/* only lower 16 bits are counted */
	idt[index].offset_2 = offset >> 16;		/* shift 16 bits right so only upper 16 bits are counted */
	idt[index].selector = selector;	
	idt[index].type = type & 0x1F;			/* only lower 5 bits are counted */
	idt[index].dpl = dpl & 0x3;				/* only lower 2 bits are counted */

	idt[index].reserved = 0x00;	
	idt[index].zero = 0x00;
	idt[index].present = 0x01;
}


/**
 * Setup everything for interrupt handling
 */
void setup_interrupts() {

	/* Sets the idtr */
	idtr.limit = (256 * 8) - 1;
	idtr.ptr = (uint32_t) idt;
	
	/* Send the exceptions interrupts to default_isr_entry (later they will have their own exception entries) */
	for( int i = 0; i < 32; ++i ) {
		setEntry(i, (uint32_t) default_isr_entry, 0x08, 0x0E, 0x00);
	}

	/* 
	 * Set the irq entries
	 * Kernel code selector 0x08, Type Interrupt Gate 0x0E, Privilege Ring 0
     */
	setEntry(IRQ00, (uint32_t) irq00_entry, 0x08, 0x0E, 0x00);
	setEntry(IRQ01, (uint32_t) irq01_entry, 0x08, 0x0E, 0x00);
	setEntry(IRQ02, (uint32_t) irq02_entry, 0x08, 0x0E, 0x00);
	setEntry(IRQ03, (uint32_t) irq03_entry, 0x08, 0x0E, 0x00);
	setEntry(IRQ04, (uint32_t) irq04_entry, 0x08, 0x0E, 0x00);
	setEntry(IRQ05, (uint32_t) irq05_entry, 0x08, 0x0E, 0x00);
	setEntry(IRQ06, (uint32_t) irq06_entry, 0x08, 0x0E, 0x00);
	setEntry(IRQ07, (uint32_t) irq07_entry, 0x08, 0x0E, 0x00);
	setEntry(IRQ08, (uint32_t) irq08_entry, 0x08, 0x0E, 0x00);
	setEntry(IRQ09, (uint32_t) irq09_entry, 0x08, 0x0E, 0x00);
	setEntry(IRQ10, (uint32_t) irq10_entry, 0x08, 0x0E, 0x00);
	setEntry(IRQ11, (uint32_t) irq11_entry, 0x08, 0x0E, 0x00);
	setEntry(IRQ12, (uint32_t) irq12_entry, 0x08, 0x0E, 0x00);
	setEntry(IRQ13, (uint32_t) irq13_entry, 0x08, 0x0E, 0x00);
	setEntry(IRQ14, (uint32_t) irq14_entry, 0x08, 0x0E, 0x00);
	setEntry(IRQ15, (uint32_t) irq15_entry, 0x08, 0x0E, 0x00);	

	load_idt();
}


/**
 * Register a custom interrupt service rounte for given interrupt number
 *
 * @param	interrupt	interrupt number
 * @param	isr			function pointer to interrupt service routine which get called on interrupt. If isr is 0, interrupt is unregistered
 */
void register_isr(uint8_t interrupt, void (*isr)(interrupt_status status)) {
	custom_isr[interrupt] = isr;
}



#define PIC1 0x20
#define PIC2 0xA0

/**
 * Handle interrupts and call custom handlers
 *
 * handle default interrupt stuff like writing to PICs and call custom isr if it exists
 */
void interrupt_handler(interrupt_status status) {
	
	/* Custom isr available */
	if( custom_isr[status.interrupt_number] != 0 ) {
		custom_isr[status.interrupt_number](status);
	}

	/* Interrupt from PIC2 */
	if( status.interrupt_number >= IRQ08 && status.interrupt_number <= IRQ15 ) {
		outb(PIC2, 0x20);
		outb(PIC1, 0x20);
	} 

	/* Interrupt from PIC1 */
	else if( status.interrupt_number >= IRQ00 && status.interrupt_number <= IRQ07 ) {
		outb(PIC1, 0x20);
	}	
}
