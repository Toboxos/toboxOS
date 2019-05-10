#include "../screen/screen.h"
#include "../sys/io.h"
#include "../types.h"

#define PIC1 0x20 // Port master PIC
#define PIC2 0xA0 // Port slave PIC

void irq_handler(uint8_t irq) {
	
	if( irq == 1 ) {
		setCursor(0, 5);

		// clear old text
		printc(' ');
		printc(' ');
		printc(' ');
		printc(' ');

		// print scancode
		setCursor(0, 5);
		printhex(inb(0x60));
	}

	// Send acknowledge code to pics
	// if irq numer is ge 8 send signal to slave too
	if( irq >= 8 ) {
		outb(PIC2, 0x20);
	}
	outb(PIC1, 0x20);
}

