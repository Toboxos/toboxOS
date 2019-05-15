#include "screen/screen.h"
#include "interrupts/interrupts.h"
#include "sys/io.h"

const char* text = "Dieser Text ist Philipp gewidmet";

void test(interrupt_status status) {
	uint8_t scancode = inb(0x60);
	
	setCursor(5, 0);
	printc(' ');
	printc(' ');
	printc(' ');
	printc(' ');
	setCursor(5, 0);
	printhex( scancode );
}

void kernel_main() {
	
	clearScreen();
	setCursor(0, 0);

	prints(text);
	
	setCursor(1, 0);
	printhex((uint32_t) kernel_main);

	setup_interrupts();
	register_isr(IRQ01, test);

	while( 1 );
}
