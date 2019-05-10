#include "screen/screen.h"
#include "interrupts/idt.h"
#include "sys/io.h"

const char* text = "Dieser Text ist Philipp gewidmet";

extern void test();

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

	init_idt();

	while( 1 );
}
