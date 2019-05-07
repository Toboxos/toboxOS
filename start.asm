[org 0x7C00]
[bits 16]
	cli
	mov [driveNumber], dl ; Save the number of current drive

	; Bootable Code will be located from 0x7C00 - 0x7E00 (512 bytes)
	; Set Stack base to 7E00
	mov ax, 0x7E0
	mov ss, ax

	; Stack pointer decreases, so move stack pointer at begin to end of stack memory
	; Stack will be 8k (2*4096) big -> Offset of stack pointer from stack base 0x2000
	mov sp, 0x2000

	call clearscreen

	push 0x00
	call setcursor
	add sp, 2

	push msg
	call print
	add sp, 2

	; Read from disk to memory - first test
	push 0x02 ; sector 2
	push 0x00 ; head 0
	push 0x00 ; cylinder 0
	push 0x01 ; read 1 sector 
	call _boot_read_disk
	add sp, 0x04


_boot_a20_check:
	call status_a20
	cmp ax, 0
	jz _boot_a20_off

_boot_a20_on:
	push s_a20_on
	call print
	add sp, 0x02

	xor ax, ax
	mov ds, ax
	lgdt [gdt]
	
	mov eax, cr0
	or eax, 0x01
	mov cr0, eax
	jmp 0x08:protected_mode

_boot_a20_off:
	push s_a20_off
	call print
	add sp, 0x02

_boot_a20_end:
	cli
	hlt
 
; arg1 = number of sectors to read
; arg2 = cylinder number
; arg3 = head number
; arg4 = sector number
_boot_read_disk:
	push bp
	mov bp, sp
	pusha  

	; Disk content will be read to address 0x9E00
	mov ax, 0x9E0
	mov es, ax
	mov bx, 0x00
	
	mov byte al, [bp+0x04]
	mov byte ch, [bp+0x06]
	mov byte dh, [bp+0x08]
	mov byte cl, [bp+0x0a]
	mov byte dl, [driveNumber]

	mov ah, 0x02 ; read from disk
	int 0x13

	popa
	mov sp, bp
	pop bp
	ret 

; Stop execution and halt machine
hlt

%include "screen.asm"
%include "a20.asm"

[bits 32]
protected_mode:
	; segment registers for data
	mov eax, 0x10
	mov ds, eax
	mov es, eax
	mov ss, eax
	mov fs, eax
	mov gs, eax

	; Stack will be 1mb big from 0x100000 to 0x1FFFFF
	mov esp, 0x1FFFFF

	; Jump to kernel here
	hlt

[bits 16]
driveNumber: db 0x00
msg: db `Hello World booted and written in Assembler\r\n\0`

s_a20_off: db `A20 Line is off\r\n\0`
s_a20_on: db `A20 Line ist on\r\n\0`


%include "gdt.asm"

; offset to partition table
times 446-($-$$) db 0

; partition 1 (bootable)
db 0x80
db 0x00, 0x01, 0x00
db 0x01
db 0x00, 0x02, 0x00
dd 0x00
dd 0x02

times 510-($-$$) db 0
dw 0xAA55

; 512 bytes (one Sector). For memory test after disk read
times 128 db 0x41
times 128 db 0x42
times 128 db 0x43
times 128 db 0x44
