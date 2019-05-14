bits 16

; clears whole screen
clearscreen:
    push bp
    mov bp, sp
    pusha

    mov ah, 0x07    ; BIOS scroll down
    mov al, 0x00    ; Number of lines (0 = clear entire screen)
    mov bh, 0x07    ; new text will be white on black
    mov cx, 0x00    ; ch, cl = row, column windows upper left corner
    mov dh, 0x18    ; dh, dl = row column window lower right corner 0x18=24 rows, 0x4f=79 cols
    mov dl, 0x4f
    int 0x10        ; interrupt bios mode

    popa
    mov sp, bp
    pop bp
    ret

; set cursor to given position
;
; arg1 = position	high 4 bits sets row, low 4 bits set column
setcursor:
    push bp
    mov bp, sp
    pusha

    mov ah, 0x02        ; BIOS set cursor
    mov bh, 0x00        ; Page number Graphics mode
    mov dx, [bp+0x4]    ; dh, dl = row,column. first argument set this
	int 0x10

    popa
    mov sp, bp
    pop bp
    ret

; prints a string to the screen at current cursor position
;
; arg1 = pointer to string
print:
    push bp
    mov bp, sp
    pusha

	; si = pointer to char of string
    mov si, [bp+0x4]
    mov ah, 0x0E
    mov bx, 0x00        ; Page number 0 and default foreground color    

print_get_char:
	
	; move current char from pointer to al
	; check if char is string terminator
	; if string is terminated jump to end
	; else print char and move to next char
    mov al, [si]
    cmp al, 0x00
    jz print_end   
	
    int 0x10	; print char
    inc si		; move pointer to next char

    jmp print_get_char	; repeat

print_end:
    popa
    mov sp, bp
    pop bp
    ret
