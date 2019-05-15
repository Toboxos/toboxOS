#ifndef KERNEL_SCREEN_H
#define KERNEL_SCREEN_H

#include "../types.h"

/** VGA Colors */
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

static const int VGA_WIDTH = 80;
static const int VGA_HEIGHT = 24;

/** 
 * Prints character to current cursor position
 *
 * @param	c	character to print
 */
extern void printc(char c);

/**
 * Prints colored character to current cursor position
 *
 * @param	c					character to print
 * @param	colorForeground		foreground color see, VGA Colors
 * @param	colorBackground		background color but only 3 bits from VGA_COLOR_BLACK - VGA_COLOR_GRAY, see VGA Colors
 * @param	blink				if character should blink
 */
extern void printc_color(char c, uint8_t colorForeground, uint8_t colorBackground, uint8_t blink);

/**
 * Prints hexadecimal value
 *
 * @param	value	32bit value which gets printed as hex
 */
extern void printhex(uint32_t value);


/**
 * Prints string to current cursor position
 *
 * @param	string	pointer to string
 */
extern void prints(const char* string);

/**
 * Moves Cursor to given position at screen
 *
 * @param 	y	row on screen. Start at 0
 * @param	x	column on screen. Start at 0
 */
extern void setCursor(uint8_t y, uint8_t x);

/**
 * Clears the whole Screen
 */
extern void clearScreen();

#endif
