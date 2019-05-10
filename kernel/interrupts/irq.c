#include "../screen/screen.h"
#include "../sys/io.h"


void irq_standard() {
	outb(0x20, 0x20);
}

void irq01() {
	printc('.');
	outb(0x20, 0x20);
}
