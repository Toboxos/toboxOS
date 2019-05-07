bits 16

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

print:
    push bp
    mov bp, sp
    pusha

    mov si, [bp+0x4]    ; First argument is pointer to string
    mov ah, 0x0E
    mov bx, 0x00        ; Page number 0 and default foreground color    

print_get_char:
    mov al, [si]
    cmp al, 0x00
    jz print_end   
    int 0x10
    inc si
    jmp print_get_char

print_end:
    popa
    mov sp, bp
    pop bp
    ret
