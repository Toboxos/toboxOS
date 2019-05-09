[bits 16]
load_kernel:
	
	; Loading first 512 bytes from kernel to memory 0xa000
	mov ax, 0xa00
	mov es, ax
	xor bx, bx

	push 0x03
	push 0x00
	push 0x00
	push 0x01
	call _boot_read_disk
	add sp, 0x08

	; copy entry point to memory
	mov word ax, [es:0x18]
	mov word [kernel_entry], ax
	mov word ax, [es:0x1A]
	mov word [kernel_entry+2], ax

	; Get the start of the programm header table
	; only the lower 2 bytes are used, saved in bx
	mov word ax, [es:0x1C]
	mov bx, ax

	; Get the size of a programm header table
	mov word ax, [es:0x2A]
	mov cx, ax

	; Get the number of entries in programm header table
	mov word ax, [es:0x2C]
	push ax

	; Calculate size of programm header table
	; ax will contain number of sectors to read for loading programm table
	mul cx
	add ax, 0x1FF ; ceil the dividing by 512
	add ax, bx	  ; add the base of the programm headter table
	mov cx, 0x200
	div cx

	; Loading programm table into memory
	push 0x03
	push 0x00
	push 0x00
	push ax
	
	mov ax, bx	; save bx and reset to 0 (for reading)
	xor bx, bx

	call _boot_read_disk
	add sp, 0x08

	; restore base offset to programm table to bx
	; restore number of entries to cx
	mov bx, ax
	pop ax
	mov cx, ax	

	push 0xbabe
	
	; protected mode will return to 4 bytes, real mode call saves only 2 bytes
	; fill 2 bytes with zero
	push 0x00
	call go_protected

; Following code is only for 32bit !!!
; it depends on the values and offset in the elf header for 32 bit
; for 64 bit change the offsets
[bits 32] ; breakpoint 0x7e5e

	; ebx = base offset of program header entry
	; ecx = number of entries left to check
	and ebx, 0xFFFF ; ensure the upper half is zero
	and ecx, 0xFFFF
	add ebx, 0xa000 ; add image base to offset

check_entry:

	; if no more entrie left to check, loader has finished
	cmp ecx, 0
	je _loader_finished

	; check if program entry is loadable
	; else check next entry
	cmp dword [ebx], 0x01
	je _loader_load_entry
	
	; move ebx to next entry, decrement remaining
	add ebx, 0x200
	dec ecx
	jp check_entry

_loader_load_entry:

	; esi = offset on disk
	add ebx, 0x04
	mov esi, [ebx]
	add esi, 0x400 ; because kernel image starts at sector 3	

	; edi = address in memory to load
	add ebx, 0x04
	mov edi, [ebx]

	; edx = size of image
	add ebx, 0x08
	mov edx, [ebx]

	add ebx, 0x10 ; mov ebx to next programm header

	push ebx
	push ecx
	push edx

	; calculate start sector of data
	xor edx, edx
	mov eax, esi
	mov ecx, 0x200
	div ecx	

	pop edx

	; esi = sector to load
	mov esi, eax
	add esi, 0x01 ; sector numbering starts at 1

; loop for loading sectors
_loader_next_sector:	
	pushad
	call go_real
[bits 16]
	call _loader_load_sector
	push 0x00 ; real call saves only 2 bytes. push 2 bytes for align with 32 bit address
	call go_protected
[bits 32]
	popad

	cmp edx, 0x200
	jc less_512

; copy 512 bytes
	push 0x200
	push edi
	push 0xb000
	call memcpy
	add esp, 0x0C
	
	; ready for next sector
	add edi, 0x200
	sub edx, 0x200
	inc esi
	jmp _loader_next_sector 

; edx contains value less than 512 -> copy remaining bytes
less_512:
	push edx
	push edi
	push 0xb000
	call memcpy
	add esp, 0x0C
	
	pop ecx
	pop ebx
	dec ecx
	jmp check_entry


_loader_finished:
	mov dword eax, [kernel_entry]
	jmp eax
	

; arg1 = source
; arg2 = dest
; arg3 = size
memcpy:
	push ebp
	mov ebp, esp
	pushad

	mov esi, [ebp+0x08]
	mov edi, [ebp+0x0C]
	mov ecx, [ebp+0x10]

memcpy_loop:
	mov eax, ecx
	cmp eax, 0x00
	je memcpy_end

	mov byte al, [esi]
	mov byte [edi], al
	
	inc esi
	inc edi
	dec ecx
	jmp memcpy_loop
	
memcpy_end:
	popad
	mov esp, ebp
	pop ebp
	ret

	
; loads setor number in si to memory location 0xb000
[bits 16]
_loader_load_sector:
	mov ax, 0xb00
	mov es, ax
	xor bx, bx

	mov ax, si
	push ax
	push 0x00
	push 0x00
	push 0x01
	call _boot_read_disk
	add sp, 0x08

	ret

	
[bits 16]
go_protected:
	; load gdt
	xor ax, ax
	mov ds, ax
	lgdt [gdt]

	; change to protected	
	mov eax, cr0
	or eax, 0x01
	mov cr0, eax
	
	jmp 0x08:protected_mode

[bits 32]
protected_mode:

	; segment data
	mov eax, 0x10
	mov ds, eax
	mov es, eax
	mov fs, eax
	mov gs, eax

	; save return address from stack
	pop eax
	mov dword [addr_return], eax

	; save RM stackpointer
	mov word [sp_rm], sp	

	mov eax, ds
	mov ss, eax
	mov esp, [sp_pm]
	
	; restore return address on stack
	mov dword eax, [addr_return]
	push eax

	ret

[bits 32]
go_real: ; breakpoint 0x7ef6
	; load gdt
	lgdt [gdt_16]

	; save ret address
	pop eax
	mov dword [addr_return], eax

	; save pm stackpointer
	mov dword [sp_pm], esp
	
	
	; sets mode to 16 bit protected
	jmp word 0x08:real_mode

[bits 16]
real_mode:
	
	; disable protected
	mov eax, cr0
	and eax, 0xFFFFFFFE
	mov cr0, eax

	jmp word 0x00:cs00 ; set cs to 00
cs00:

	mov ax, 0x00
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	mov ax, 0x7e0
	mov ss, ax

	xor esp, esp
	mov sp, [sp_rm]
	
	; restore return address
	mov word ax, [addr_return]
	push ax

	ret
	

[bits 16]
s_test: db `test\r\n\0`

; when switching between RM and PM return address, stackpointer RM & stackpointer PM can saved here
addr_return: dd 0
sp_rm: dw 0
sp_pm: dd 0x1FFFFF

kernel_entry: dd 0x00 ; Entry point of kernel is saved here and jumped to later

; Padding with zeros, so kernel code is aligend on sector 3
times 1024-($-$$ ) db 0
