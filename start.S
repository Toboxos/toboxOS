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

; Stop execution and halt machine
cli
hlt

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

driveNumber: db 0x00
msg: db "Hello World booted and written in Assembler"

times 510-($-$$) db 0
dw 0xAA55

; 512 bytes (one Sector). For memory test after disk read
times 128 db 0x41
times 128 db 0x42
times 128 db 0x43
times 128 db 0x44
