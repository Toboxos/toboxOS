[bits 32]
global irq00_entry
global irq01_entry
global irq02_entry
global irq03_entry
global irq04_entry
global irq05_entry
global irq06_entry
global irq07_entry
global irq08_entry
global irq09_entry
global irq10_entry
global irq11_entry
global irq12_entry
global irq13_entry
global irq14_entry
global irq15_entry

extern interrupt_handler

; pushes all needed information for interrupt_status (see interrupts.h) on stack and call interrupt_handler (see interrupts.c)
; after return it clears up the stack and retun from interrupt
isr_entry:
	; push general-purpose registers for interrupt_status
	pushad
	
	; push segment register for interrupt_status
	push gs
	push fs
	push es
	push ds

	; set data segment registers to kernel data gdt entry
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	call interrupt_handler
	
	; pop segment registers 
	pop ds
	pop es
	pop fs
	pop gs
	
	; pop general-purpose registers
	popad
	
	; moves the stack pointer over the interrupt number and error code (2 * 4 bytes = 8 bytes)
	add esp, 0x08

	iret


; here are the corresponding interrupt numbers
; interrupts not remapped yet, numbers will change in future
irq00 equ 0x08
irq01 equ 0x09
irq02 equ 0x0A
irq03 equ 0x0B
irq04 equ 0x0C
irq05 equ 0x0D
irq06 equ 0x0E
irq07 equ 0x0F
irq08 equ 0x70
irq09 equ 0x71
irq10 equ 0x72
irq11 equ 0x73
irq12 equ 0x74
irq13 equ 0x75
irq14 equ 0x76
irq15 equ 0x77

; each entry pushes the error code 0x00 on stack
; then pushes its interrupt number
; and finnaly jumps to isr_entry
irq00_entry: 
	push 0x00
	push irq00
	jmp isr_entry

irq01_entry: 
	push 0x00
	push irq01
	jmp isr_entry

irq02_entry: 
	push 0x00
	push irq02
	jmp isr_entry

irq03_entry: 
	push 0x00
	push irq03
	jmp isr_entry

irq04_entry: 
	push 0x00
	push irq04
	jmp isr_entry

irq05_entry: 
	push 0x00
	push irq05
	jmp isr_entry

irq06_entry: 
	push 0x00
	push irq06
	jmp isr_entry

irq07_entry: 
	push 0x00
	push irq07
	jmp isr_entry

irq08_entry: 
	push 0x00
	push irq08
	jmp isr_entry

irq09_entry: 
	push 0x00
	push irq09
	jmp isr_entry

irq10_entry: 
	push 0x00
	push irq10
	jmp isr_entry

irq11_entry: 
	push 0x00
	push irq11
	jmp isr_entry

irq12_entry: 
	push 0x00
	push irq12
	jmp isr_entry

irq13_entry: 
	push 0x00
	push irq13
	jmp isr_entry

irq14_entry: 
	push 0x00
	push irq14
	jmp isr_entry

irq15_entry: 
	push 0x00
	push irq15
	jmp isr_entry
