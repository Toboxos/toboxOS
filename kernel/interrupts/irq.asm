[bits 32]
global standard_isr_entry


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

extern irq_handler

standard_isr_entry:
	pushad

	push 0xFF ; some number which not getting handled. dummy
	call irq_handler
	pop eax

	popad
	iret

; each irq entry pushes the irq number on stack and calling the irq handler
; the irq handle can check the number and proceed in c
irq00_entry:
	pushad

	push 0x00
	call irq_handler
	pop eax

	popad
	iret

irq01_entry:
	pushad

	push 0x01
	call irq_handler
	pop eax

	popad
	iret

irq02_entry:
	pushad

	push 0x02
	call irq_handler
	pop eax

	popad
	iret

irq03_entry:
	pushad

	push 0x03
	call irq_handler
	pop eax

	popad
	iret

irq04_entry:
	pushad

	push 0x04
	call irq_handler
	pop eax

	popad
	iret

irq05_entry:
	pushad

	push 0x05
	call irq_handler
	pop eax

	popad
	iret

irq06_entry:
	pushad

	push 0x06
	call irq_handler
	pop eax

	popad
	iret

irq07_entry:
	pushad

	push 0x07
	call irq_handler
	pop eax

	popad
	iret

irq08_entry:
	pushad

	push 0x08
	call irq_handler
	pop eax

	popad
	iret

irq09_entry:
	pushad

	push 0x09
	call irq_handler
	pop eax

	popad
	iret

irq10_entry:
	pushad

	push 0x10
	call irq_handler
	pop eax

	popad
	iret

irq11_entry:
	pushad

	push 0x11
	call irq_handler
	pop eax

	popad
	iret

irq12_entry:
	pushad

	push 0x12
	call irq_handler
	pop eax

	popad
	iret

irq13_entry:
	pushad

	push 0x13
	call irq_handler
	pop eax

	popad
	iret

irq14_entry:
	pushad

	push 0x14
	call irq_handler
	pop eax

	popad
	iret

irq15_entry:
	pushad

	push 0x15
	call irq_handler
	pop eax

	popad
	iret
