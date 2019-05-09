extern idtr
global load_idt

; Loads the address of idtr defined in idt.c into idt register
load_idt:
	push ebp
	mov ebp, esp
	pushad

	lidt [idtr]

	popad
	mov esp, ebp
	pop ebp
	ret
