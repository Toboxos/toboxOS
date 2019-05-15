#include "screen.h"


/*
 * Representation of one entry in the vga video buffer
 */
typedef struct {
	uint8_t character;					/** ASCII Character */
	struct {	
		uint8_t colorForeground	: 4;	/** Foregorund color */
		uint8_t colorBackground	: 3;	/** Background color */
		uint8_t blink			: 1;	/** 1 = Chracter blinking, 0 = Character not blinking */
	} attribute;
} vga_text_entry;

/** Buffer to mapped memory for vga text mode */
static vga_text_entry* vga_data = (vga_text_entry*) 0xB8000;

/** Holds current cursor position */
struct {
	uint8_t x;	/** Current y-Position */
	uint8_t y;	/** Current x-Position */
} cursor = {0};

void printc(char c) {
	printc_color(c, VGA_COLOR_WHITE, VGA_COLOR_BLACK, 0);
}

void printc_color(char c, uint8_t colorForeground, uint8_t colorBackground, uint8_t blink) {
	
	/* New Line */
	if( c == '\n' ) {
		/* Implement scrolling later */
		if( ++cursor.y >= VGA_HEIGHT ) {

		}
		return;
	}	

	/* Carriage Return */
	if( c == '\r' ) {
		cursor.x = 0;
		return;
	}

	/* Sets the attribute of the appropiate entry */
	vga_data[cursor.y * VGA_WIDTH + cursor.x].character = c;
	vga_data[cursor.y * VGA_WIDTH + cursor.x].attribute.colorForeground = colorForeground;
	vga_data[cursor.y * VGA_WIDTH + cursor.x].attribute.colorBackground = colorBackground;
	vga_data[cursor.y * VGA_WIDTH + cursor.x].attribute.blink = blink;

	/* Cursor would be on end of line */
	if( ++cursor.x >= VGA_WIDTH ) {
		cursor.x = 0;		

		/* Implement scrolling later */
		if( ++cursor.y > VGA_HEIGHT ) {

		}
	}
}


void printhex(uint32_t value) {

	/* Stop recursion and print prefix */
	if( value == 0 ) {
		printc('0');
		printc('x');
		return;
	}	
	
	/* Recursion before printing -> highest value is printed first */
	printhex(value / 16);

	/* Calculate remainder and check if its normal number or letter */
	int remainder = value % 16;
	if( remainder < 10 ) {
		printc('0' + remainder);
	} else {
		printc('A' + remainder - 10);
	}

}

void prints(const char* string) {
	for( uint32_t i = 0; string[i] != '\0'; ++i ) {
		printc(string[i]);
	}
}


void setCursor(uint8_t y, uint8_t x) {

	/* Bound check for cursor */
	if( y >= VGA_HEIGHT || x >= VGA_WIDTH ) return;

	cursor.x = x;
	cursor.y = y;
}

/**
 * @details	Writes to each byte in VGA text memory 0x00
 */
void clearScreen() {
	char* base = (char*) vga_data;
	for( int i = 0; i < VGA_WIDTH * VGA_HEIGHT * 2; ++i ) {
		base[i] = 0;
	}
}
