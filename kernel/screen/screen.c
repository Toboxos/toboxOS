#include "screen.h"

void printc(uint8_t x, uint8_t y, char c) {
	printc_color(x, y, c, VGA_COLOR_WHITE, VGA_COLOR_BLACK, 0);
}

void printc_color(uint8_t x, uint8_t y, char c, uint8_t colorForeground, uint8_t colorBackground, uint8_t blink) {
	vga_data[y * vga_height + x].character = c;
	vga_data[y * vga_height + x].attribute.colorForeground = colorForeground;
	vga_data[y * vga_height + x].attribute.colorBackground = colorBackground;
	vga_data[y * vga_height + x].attribute.blink = blink;
}

void clearscreen() {
	for( int y = 0; y < vga_height; ++y ) {
		for( int x = 0; x < vga_width; ++x ) {
			printc(y, x, ' ');
		}
	}
}
