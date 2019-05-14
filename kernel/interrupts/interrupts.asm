global load_idt
global default_isr_entry

extern idtr
extern interrupt_handler

; Loads the address of idtr to internal idtr register
load_idt:
	push ebp
	mov ebp, esp
	pushad

	lidt [idtr]	; idtr defined in interrupts.c
	sti

	popad
	mov esp, ebp
	pop ebp
	ret


; Handle interrupts with are currently have no own entry
default_isr_entry:
	iret
