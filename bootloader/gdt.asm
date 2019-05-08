bits 16

gdt:
	dw gdt_end - gdt_null
	dq gdt_null

; GDT null segment
gdt_null:
	dq 0

; GDT code segment (4GB)
gdt_code:
	dw 0xFFFF
	dw 0x00
	db 0x00
	db 10011010b
	db 11001111b
	db 0x00

; GDT data segment (4GB)
gdt_data:
	dw 0xFFFF
	dw 0x00
	db 0x00
	db 10010010b
	db 11001111b
	db 0x00

gdt_end:

; same as normal gdt but 16 bit
gdt_16:
	dw gdt_16_end - gdt_16_null
	dq gdt_16_null

gdt_16_null:
	dq 0

gdt_16_code:
	dw 0xFFFF
	dw 0x00
	db 0x00
	db 10011010b
	db 00001111b
	db 0x00

gdt_16_data:
	dw 0xFFFF
	dw 0x00
	db 0x00
	db 10010010b
	db 00001111b
	db 0x00

gdt_16_end:
