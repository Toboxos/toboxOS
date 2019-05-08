typedef unsigned char uint8_t;

typedef struct {
	uint8_t character;
	struct {
		uint8_t colorForeground : 4;
		uint8_t colorBackground : 3;
		uint8_t blink			: 1;
	} attribute;
} vga_text_data;

static vga_text_data* vga_buffer = (vga_text_data*) 0xB8000;
const char kernel_text[] = "This string is brought to you by the first lines of c kernel";

void kernel_main() {
	for( int i = 0; kernel_text[i] != '\0'; ++i ) {
		vga_buffer[i].character = kernel_text[i];
	}

	while( 1 );
}
