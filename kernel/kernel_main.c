#include "screen/screen.h"
#include "interrupts/interrupts.h"
#include "sys/io.h"

const char* text = "Dieser Text ist Philipp gewidmet";

void test(interrupt_status status) {
	uint8_t scancode = inb(0x60);
	
	setCursor(0, 5);
	printc(' ');
	printc(' ');
	printc(' ');
	printc(' ');
	setCursor(0, 5);
	printhex( scancode );
}

void kernel_main() {
	outb(0xe9, 'H');
	outb(0xe9, 'E');
	outb(0xe9, 'Y');
	
	clearscreen();
	setCursor(0, 0);

	for( int i = 0; text[i] != '\0'; ++i ) {
		printc(text[i]);
	}
	
	setCursor(0, 1);
	printhex(kernel_main);

	setup_interrupts();
	register_isr(IRQ01, test);

	while( 1 );
}
