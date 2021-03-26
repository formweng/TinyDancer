    kernaloffset equ 0x0100
    kernalseg equ 0x1000

    org 0x7c00

    mov ax,cs
    mov ds,ax
    mov ds,ax
    mov ss,ax

    mov ax,kernalseg
    mov es,ax
    mov bx,kernaloffset
    mov al,11;读写扇区数
    mov ah,2;读函数
    mov cl,8;起始扇区号S
    mov ch,0;柱面号C
    mov dl,0;磁盘号，0表示第一个映像文件
    mov dh,0;磁头号0/1，H
    int 0x13

    jmp kernalseg:kernaloffset

times 510-($-$$) db 0
dw 0xaa55