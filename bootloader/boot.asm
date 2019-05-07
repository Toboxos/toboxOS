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

_boot_a20_check:
	call status_a20
	cmp ax, 0
	jz _boot_a20_off

_boot_a20_on:
	push s_a20_on
	call print
	add sp, 0x02

	; Loading code of loader.asm into memory at 0x7e00
	mov ax, 0x7e0
	mov es, ax
	mov bx, 0x00
	
	push 0x02 
	push 0x00
	push 0x00
	push 0x01
	call _boot_read_disk
	add sp, 0x08

	push s_jump_loader
	call print
	add sp, 0x02

	jmp load_kernel

_boot_a20_off:
	push s_a20_off
	call print
	add sp, 0x02

_boot_a20_end:
	cli
	hlt
 
; writes data to address pointed by bs:bx
; arg1 = number of sectors to read
; arg2 = cylinder number
; arg3 = head number
; arg4 = sector number
_boot_read_disk:
	push bp
	mov bp, sp
	pusha  

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

%include "bootloader/screen.asm"
%include "bootloader/a20.asm"

[bits 16]
driveNumber: db 0x00
msg: db `Hello World booted and written in Assembler\r\n\0`

s_a20_off: db `A20 Line is off\r\n\0`
s_a20_on: db `A20 Line ist on\r\n\0`
s_jump_loader: db `Jumping to kernel loader...\r\n\0`

%include "bootloader/gdt.asm"

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

%include "bootloader/loader.asm"
