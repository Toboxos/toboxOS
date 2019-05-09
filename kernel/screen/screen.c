#include "screen.h"

int cursorX = 0;
int cursorY = 0;

void printc(char c) {
	printc_color(c, VGA_COLOR_WHITE, VGA_COLOR_BLACK, 0);
}

void printc_color(char c, uint8_t colorForeground, uint8_t colorBackground, uint8_t blink) {
	if( c == '\n' ) {
		/* Implement scrolling later */
		if( ++cursorY > vga_height ) {

		}
		return;
	}	

	if( c == '\r' ) {
		cursorX = 0;
		return;
	}

	vga_data[cursorY * vga_width + cursorX].character = c;
	vga_data[cursorY * vga_width + cursorX].attribute.colorForeground = colorForeground;
	vga_data[cursorY * vga_width + cursorX].attribute.colorBackground = colorBackground;
	vga_data[cursorY * vga_width + cursorX].attribute.blink = blink;

	if( ++cursorX > vga_width ) {
		cursorX = 0;		

		/* Implement scrolling later */
		if( ++cursorY > vga_height ) {

		}
	}
}


void printhex(uint32_t value) {
	if( value == 0 ) {
		printc('0');
		printc('x');
		return;
	}	
	
	// Recursion before printing -> highest value is printed first
	printhex(value / 16);

	int remainder = value % 16;
	if( remainder < 10 ) {
		printc('0' + remainder);
	} else {
		printc('A' + remainder - 10);
	}

}

void setCursor(int x, int y) {
	cursorX = x;
	cursorY = y;
}

void clearscreen() {
	char* base = (char*) vga_data;
	for( int i = 0; i < vga_width * vga_height * 2; ++i ) {
		base[i] = 0;
	}
}
