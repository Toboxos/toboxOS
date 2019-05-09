#include "screen/screen.h"
#include "interrupts/idt.h"

const char* text = "Dieser Text ist Philipp gewidmet";

extern void test();

void kernel_main() {
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
