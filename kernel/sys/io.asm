global outb
global inb

; writes given byte to given port
; arg1 = port 16 bits
; arg2 = byte  8 bits
outb:
	mov word dx, [esp+0x04] ; arg1 in dx
	mov byte ax, [esp+0x08]	; arg2 in ax

	out dx, al
	ret

; reads 1 byte from given port
; arg1 = port 16 bits
inb:
	mov word dx, [esp+0x04] ; arg 1 in dx
	xor eax, eax
	in al, dx
	ret
