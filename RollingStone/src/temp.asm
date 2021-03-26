    org 0x100

    mov ax,cs
    mov ds,ax
    mov dx,message
    mov ah,0x09
    int 21h
    ret
    
Data:
    message db 'hello$'