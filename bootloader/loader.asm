[bits 16]

; the kernel is saved in the elfi386 format
; this loaders loads the first 512 bytes including the header
; 
; from the headers following information are extracted:
; 	* kernel_entry
;	* programm_table
;
; check each entry in programm table
; if the entry is loadable load the image to desired address:
;	read 512 byte from disk and write them to destination address
;	if more bytes remaining do it again 
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
	; cause entry point is 32bit big it has to be done in 2 steps
	mov word ax, [es:0x18]
	mov word [kernel_entry], ax
	mov word ax, [es:0x1A]
	mov word [kernel_entry+2], ax

	; bx = 	offset if programm header table from elf-image start
	; 		only the lower 2 bytes are used, saved in bx
	mov word ax, [es:0x1C]
	mov bx, ax

	; cx = 	size of one entry of programm table header
	;		this should be 32bit
	mov word ax, [es:0x2A]
	mov cx, ax

	; Get the number of entries in programm header table
	; save this on stack
	mov word ax, [es:0x2C]
	push ax

	; Calculate size of programm header table in sectors
	;
	; size_in_bytes = size_of_entry * number_of_entries
	; size_in_sectors = (size_in_bytes + 511) / 512
	;
	; size_in_bytes must be ceiled to the next multiply of 512 
	;
	; ax = number of sectors to read for loading programm table
	mul cx
	add ax, 0x1FF ; ceil the dividing by 512
	add ax, bx	  ; add the base of the programm headter table
	mov cx, 0x200
	div cx

	; Loading programm table into memory to 0xa000
	push 0x03
	push 0x00
	push 0x00
	push ax
	
	mov ax, bx	; save bx and reset to 0 (for reading)
	xor bx, bx

	call _boot_read_disk
	add sp, 0x08

	; restore base offset to programm table to bx
	; cx = number of entries in programm table
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

	; check if more programm header entries have to be checked
	; if true jump
	cmp ecx, 0
	je _loader_finished

	; if program entry is loadable load entry
	; else check next entry
	cmp dword [ebx], 0x01
	je _loader_load_entry
	
	; move ebx to next entry, decrement remaining
	add ebx, 0x200
	dec ecx
	jp check_entry

_loader_load_entry:

	; esi = offset in bytes on disk
	add ebx, 0x04
	mov esi, [ebx]
	add esi, 0x400 ; because kernel image starts at sector 3	

	; edi = address in memory to load
	add ebx, 0x04
	mov edi, [ebx]

	; edx = remaining size in bytes of image
	add ebx, 0x08
	mov edx, [ebx]

	add ebx, 0x10 ; mov ebx to next programm header

	push ebx
	push ecx
	push edx

	; calculate start sector of data by dividing by 512
	; result is start sector when first sector would be 0
	xor edx, edx
	mov eax, esi
	mov ecx, 0x200
	div ecx	

	pop edx

	; esi = sector to load
	; because sector numbering starts at 1, translate the start sector to right value
	mov esi, eax
	add esi, 0x01

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

	; check if remaining bytes are less than 512 bytes
	; jump if true
	cmp edx, 0x200
	jc less_512

	; copy 512 bytes from loaded memory location to destination memory address 
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

; edx contains value less than 512 -> copy only remaining bytes
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


; loader finished loading all images from programm table to memory. Now jump to the entry point
_loader_finished:
	mov dword eax, [kernel_entry]
	jmp eax
	

; copies n bytes from source to destination
;
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

; goes from 16 bit real mode to 32 bit protected mode
; returns to caller address after done and proceed in protected mode
[bits 16]
go_protected:
	
	; load gdt with 32bit segments
	xor ax, ax
	mov ds, ax
	lgdt [gdt]

	; go into 16bit protected mode
	mov eax, cr0
	or eax, 0x01
	mov cr0, eax
	
	; go into 32 bit mode with jumping to a segment which is 32bit in the GDT
	jmp 0x08:protected_mode

[bits 32]
protected_mode:

	; set the segment descriptors to the kernel data segment
	mov eax, 0x10
	mov ds, eax
	mov es, eax
	mov fs, eax
	mov gs, eax

	; save return address from stack to temporary memory
	pop eax
	mov dword [addr_return], eax

	; saves actual stackpointer for real mode
	mov word [sp_rm], sp	

	; load saved protected mode stack pointer and change stacksegment to kernel data segment
	mov eax, ds
	mov ss, eax
	mov esp, [sp_pm]
	
	; restore saved return addres to new stack
	mov dword eax, [addr_return]
	push eax

	ret


; goes from 32 bit protected mode to 16 bit real mode
; returnto caller address after done and proceed in real mode 
[bits 32]
go_real:
	
	; load gdt width 16 bit segments
	lgdt [gdt_16]

	; save return address from stack to temporary memory
	pop eax
	mov dword [addr_return], eax

	; saves protected mode stack pointer because address is to high to used in real mode
	mov dword [sp_pm], esp
	
	; goes to 16 bit mode with jumping to a segment wich is 16 bit in GDT
	jmp word 0x08:real_mode

[bits 16]
real_mode:
	
	; disable protected only here. Protecded mode is needed for chaning to 16 bit
	; because otherwise processor would ignore GDT
	mov eax, cr0
	and eax, 0xFFFFFFFE
	mov cr0, eax

	; jump can be done only here because in real mode GDT is ignored. otherwise it would be the zero segment in GDT
	jmp word 0x00:cs00 ; set cs to 00
cs00:

	; update the data to start of memory
	mov ax, 0x00
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	; restore the stack segment offset
	mov ax, 0x7e0
	mov ss, ax

	; make sure esp is 0
	; load stack pointer for real mode
	xor esp, esp
	mov sp, [sp_rm]
	
	; restore return address on current stack
	mov word ax, [addr_return]
	push ax

	ret
	

[bits 16]
s_test: db `test\r\n\0`

; when switching between RM and PM return address, stackpointer RM & stackpointer PM are saved here
addr_return: dd 0
sp_rm: dw 0
sp_pm: dd 0x1FFFFF

kernel_entry: dd 0x00 ; Entry point of kernel is saved here and jumped to later

; Padding with zeros, so kernel code is aligend on sector 3
times 1024-($-$$ ) db 0
