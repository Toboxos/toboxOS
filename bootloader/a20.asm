bits 16

; this functions tests if the a20 line is enabled or disabled
; the result is returned in ax. 1 = enabled, 0 = disabled
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
	mov di, 0x7e0f	; 0xffff + 0x7e0f = 0x7dff -> same address if a20 is disabled

	; save value from before
	mov byte al, [es:di]
	mov bl, al
	mov byte al, [ds:si]
	mov cl, al

	; when a20 line is not enabled [es:di] = [ds:si]
	; write a value to [es:di]
	; write value to [ds:si]
	; when a20 line is not enabled [es:di] should be overwritten
	mov byte [es:di], 0x00
	mov byte [ds:si], 0xFF	
	cmp byte [es:di], 0xFF

	; restore values
	mov al, bl
	mov byte [es:di], al
	mov al, cl
	mov byte [ds:si], al
	
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
