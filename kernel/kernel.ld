ENTRY(kernel_main)

SECTIONS {
	. = 0x200000;
	.text : {
		*(.text)
	}
}
