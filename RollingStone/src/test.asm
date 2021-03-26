BITS 16
global _start
extern main
_start:
    int 0x22
    mov ax,cs
    mov ds,ax
    mov ss,ax
    mov es,ax
    push word 0x0000
    call main
    ret