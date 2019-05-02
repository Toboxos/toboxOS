org 0x7C00
bits 16

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

	; Buffer for reading from disk
	mov ax, 0x9E0
	mov es, ax
	mov bx, 0x00

	mov ah, 0x02 		  ; read from disk
	mov al, 0x01 		  ; read 1 sector
	mov ch, 0x00 		  ; track number 0
	mov cl, 0x02 		  ; sector number 2
	mov dh, 0x00 		  ; head number 0
	mov dl, [driveNumber] ; use saved drive number
	int 0x13			  ; BIOS disk interrupt	


	call status_a20
	cmp ax, 0
	jz _boot_a20_off

	push s_a20_on
	call print
	add sp, 0x02
	jmp _boot_a20_end

_boot_a20_off:
	push s_a20_off
	call print
	add sp, 0x02

_boot_a20_end:

; Stop execution and halt machine
cli
hlt

%include "screen.asm"

status_a20:
	push bp
	mov bp, sp
	pusha
	push ds
	push es
	
	xor eax, eax	; set eax 0x00
	mov ds, eax
	not eax			; set eax 0xffff
	mov es, eax

	mov si, 0x7dff
	mov di, 0x7e0f

	; when a20 line is not enabled [es:di] = [ds:si]
	; write a value to [es:di]
	; write value to [ds:si]
	; when a20 line is not enabled [es:di] should be overwritten
	mov byte [es:di], 0x00
	mov byte [ds:si], 0xFF	
	cmp byte [es:di], 0xFF
	
	pop es
	pop ds
	popa

	; set a to 0
	; when [es:di] = [ds:si] than jump to end
	; else set a to 1 (a20 ist enabled)
	mov ax, 0x00
	jz status_a20_end
	mov ax, 0x01
status_a20_end:
	mov sp, bp
	pop bp
	ret



driveNumber: db 0x00
msg: db `Hello World booted and written in Assembler\r\n\0`

s_a20_off: db `A20 Line is off\r\n\0`
s_a20_on: db `A20 Line ist on\r\n\0`

times 510-($-$$) db 0
dw 0xAA55

; 512 bytes (one Sector). For memory test after disk read
times 128 db 0x41
times 128 db 0x42
times 128 db 0x43
times 128 db 0x44
