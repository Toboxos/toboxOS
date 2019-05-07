load_kernel:
	
	push s_test
	call print
	add sp, 0x02

	cli
	hlt


goto_protected:
	xor ax, ax
	mov ds, ax
	lgdt [gdt]

	mov eax, cr0
	or eax, 0x01
	mov cr0, eax
	jmp 0x08:protected_mode

[bits 32]
protected_mode:
	; segment data
	mov eax, 0x10
	mov ds, eax,
	mov es, eax
	mov ss, eax
	mov fs, eax
	mov gs, eax

	; Stack will be 1mb big from 0x100000 to 0x1FFFFF
	mov esp, 0x1FFFFF

	; jmp to kernel here
	hlt

[bits 16]
s_test: db `test\r\n\0`
