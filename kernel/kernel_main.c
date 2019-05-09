#include "screen/screen.h"

const char* text = "Dieser Text ist Philipp gewidmet";


void kernel_main() {
	clearscreen();
	for( int i = 0; text[i] != '\0'; ++i ) {
		printc(i, 0, text[i]);
	}
	while( 1 );
}
