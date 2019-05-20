#include "keyboard.h"
#include "../interrupts/interrupts.h"
#include "../screen/screen.h"

char scancode_table[] = {
	0x80,		// 00
	0x80,		// 01
	'1', 	// 02
	'2',	// 03
	'3',	// 04
	'4',	// 05
	'5',	// 06
	'6',	// 07
	'7',	// 08
	'8',	// 09
	'9',	// 0A
	'0',	// 0B
	'-',	// 0C
	'=',	// 0D
	'\b',	// 0E
	'\t',	// 0F
	'q',	// 10
	'w',	// 11
	'e',	// 12
	'r',	// 13
	't',	// 14
	'y',	// 15
	'u',	// 16
	'i',	// 17
	'o',	// 18
	'p',	// 19
	'[',	// 1A
	']',	// 1B
	'\n',	// 1C
	0x80,	// 1D
	'a',	// 1E
	's',	// 1F
	'd',	// 20
	'f',	// 21
	'g', 	// 22
	'h',	// 23
	'j',	// 24
	'k',	// 25
	'l',	// 26
	';',	// 27
	'\'',	// 28
	0x80,	// 29
	0x80,	// 2A
	'\\',	// 2B
	'z',	// 2C
	'x',	// 2D
	'c',	// 2E
	'v',	// 2F
	'b',	// 30
	'n',	// 31
	'm', 	// 32
	',',	// 33
	'.',	// 34
	'/',	// 35
	0x80,	// 36
	0x80,	// 37
	0x80,	// 38
	' ',	// 39
	0x80,	// 3A
	0x80,	// 3B
	0x80,	// 3C
	0x80,	// 3D
	0x80,	// 3E
	0x80,	// 3F
	0x80,	// 40
	0x80,	// 41
	0x80, 	// 42
	0x80,	// 43
	0x80,	// 44
	0x80,	// 45
	0x80,	// 46
	0x80,	// 47
	0x80,	// 48
	0x80,	// 49
	0x80,	// 4A
	0x80,	// 4B
	0x80,	// 4C
	0x80,	// 4D
	0x80,	// 4E
	0x80,	// 4F
	0x80,	// 40
	0x80,	// 41
	0x80, 	// 42
	0x80,	// 43
	0x80,	// 44
	0x80,	// 45
	0x80,	// 46
	0x80,	// 47
	0x80,	// 48
	0x80,	// 49
	0x80,	// 4A
	0x80,	// 4B
	0x80,	// 4C
	0x80,	// 4D
	0x80,	// 4E
	0x80,	// 4F
	0x80,	// 50
	0x80,	// 51
	0x80, 	// 52
	0x80,	// 53
	0x80,	// 54
	0x80,	// 55
	0x80,	// 56
	0x80,	// 57
	0x80,	// 58
	0x80,	// 59
	0x80,	// 5A
	0x80,	// 5B
	0x80,	// 5C
	0x80,	// 5D
	0x80,	// 5E
	0x80,	// 5F





};

/** 
 * Max input length 500
 */
char input_buffer[500];

char* input_pointer = input_buffer;

/**
 * Last keyboard code saved here
 */
uint8_t last_code = 0;

uint8_t input_flag = 0;
const char* input() {
	input_flag = 1;
	while( scancode_table[last_code & 0x7F] != '\n' || !(last_code & 0x80));
	input_flag = 0;
	last_code = 0;

	*(--input_pointer) = 0x00;
	input_pointer = input_buffer;
	return input_pointer; 
}

#define KEYBOARD_PORT 0x60

/**
 * Handles interrupt of keyboard
 */
void keyboard_interrupt(interrupt_status status) {
	last_code = inb(KEYBOARD_PORT);

	/* Check MSB if set */
	uint8_t key_released = last_code & 0x80;

	/* Unset MSB for code */
	uint8_t code  = last_code & 0x7F;
	
	/* If key is pressed */
	if( !key_released ) {
	
		/* Check MSB of table entry at code
		 * If set, the key is no character but functional 
         * If not set the key is a character key
         */	
		if( (scancode_table[code] & 0x080) == 0 && input_flag ) {

            if( scancode_table[code] == '\b' ) {
                if( input_pointer > input_buffer ) {
                    --input_pointer;
                    printc('\b');
                }
            }

			/* Bound check, prevent buffer overflow */
            else if ( input_pointer < input_buffer + 500 ) {
				*input_pointer = scancode_table[code];
				++input_pointer;

				printc(scancode_table[code]);
			}
		}
	}
}


void setup_keyboard() {
	register_isr(IRQ01, keyboard_interrupt);
}

