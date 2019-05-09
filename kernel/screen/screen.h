#ifndef KERNEL_SCREEN_H
#define KERNEL_SCREEN_H

#include "../types.h"

typedef struct {
	uint8_t character;
	struct {
		uint8_t colorForeground : 4;
		uint8_t colorBackground : 3;
		uint8_t blink			: 1;
	} attribute;
} vga_text_entry;

enum {
	VGA_COLOR_BLACK = 0,
	VGA_COLOR_BLUE,
	VGA_COLOR_GREEN,
	VGA_COLOR_CYAN,
	VGA_COLOR_RED,
	VGA_COLOR_MAGENTA,
	VGA_COLOR_BROWN,
	VGA_COLOR_GRAY,
	VGA_COLOR_DARK_GRAY,
	VGA_COLOR_LIGHT_BLUE,
	VGA_COLOR_LIGHT_GREEN,
	VGA_COLOR_LIGH_CYAN,
	VGA_COLOR_LIGHT_RED,
	VGA_COLOR_LIGHT_MAGENTA,
	VGA_COLOR_YELLOW,
	VGA_COLOR_WHITE
};

static vga_text_entry* vga_data = (vga_text_entry*) 0xB8000;
static const int vga_width = 80;
static const int vga_height = 24;

extern void printc(uint8_t x, uint8_t y, char c);
extern void printc_color(uint8_t x, uint8_t y, char c, uint8_t colorForeground, uint8_t colorBackground, uint8_t blink);

extern void clearscreen();

#endif
