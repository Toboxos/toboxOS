#include "screen/screen.h"
#include "interrupts/interrupts.h"
#include "keyboard/keyboard.h"
#include "sys/io.h"
#include "sys/mem.h"

const char* text = "Dieser Text ist Philipp gewidmet";

void kernel_main() {
	setup_interrupts();
	setup_keyboard();

	clear_screen();
	set_cursor(0, 0);
	prints(text);

	while( 1 ) {
		prints("\n\r>>>");
		const char* t = input();
		prints("\rYou typed: ");
		prints(t);
	}
}
