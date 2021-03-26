	
    Delay equ 50000
    DDelay equ 1000


	org 0x100
    push di
    mov di,bp 

    ; mov bp, Message		 	; BP=当前串的偏移地址
	; mov ax, ds		       	; ES:BP = 串地址
	; mov es, ax		       	; 置ES=DS
	; mov cx, MessageLength   ; CX = 串长（=9）
	; mov ax, 0x1301		 	; AH = 13h（功能号）、AL = 01h（光标置于串尾）
	; mov bx, 0x0007		 	; 页号为0(BH = 0) 黑底白字(BL = 07h)
    ; mov dh, 0		       	; 行号=0
	; mov dl, 0			 	; 列号=0
	; int 0x10			 	; BIOS的10h功能：显示一行字符

    mov al,0x01
    mov bp, Rolling
    mov cx, Rlen   
	mov ax, 0x1301		 	
	mov bx, 0x0007		 	
    mov dh, 18		       	
	mov dl, 16			 	
	int 0x10	

    mov bp, Stone
    mov cx, Slen
	mov ax, 0x1301		 	
	mov bx, 0x0007		 	
    mov dh, 19	       	
	mov dl, 17			 	
	int 0x10			 	

    mov di,bp
    pop di
    mov ax,0xb800
	mov es,ax

    mov byte[count],0xff
START:
    call ROLLING
    call DELAY
    ; call Read_Char
    ; cmp ax,0x2e03
    ; je  return
	; jmp START
    dec byte[count]
    jne START

return:
    ret

; Read_Char:;从键盘读一个字符保存到ax（ah->打印，al->ascii）中，没有则置0
;     mov ah,0x01
;     int 0x16
;     jnz s
;     mov ax,0
;     jmp end
;     s:
;     mov ah,0x00
;     int 0x16
;     end:
;     ret

ROLLING:
    call ADRESS
    call SHOW
    call UPDATA
    ret

UPDATA:
    mov ax,[pos]
    mov bx,[dir]

    add ah,bh
    add al,bl
    cmp ax,0x0c11
    jne @1
    mov bx,0x0101;(1,1)
    @1:
    cmp ax,0x1318
    jne @2
    mov bx,0x01ff;(1,-1)
    @2:
    cmp ax,0x1a11
    jne @3
    mov bx,0xffff;(-1,-1)
    @3:
    cmp ax,0x160d
    jne @4
    mov bx,0xff01;(-1,1)
    @4:
    cmp ax,0x1310
    jne @5
    mov bx,0xffff;(-1,-1)
    @5:
    cmp ax,0x100d
    jne @6
    mov bx,0xff01;(-1,1)
    @6:
    mov [pos],ax
    mov [dir],bx
	ret

ADRESS:
    mov ax,0
    mov bx,[pos]
    mov al,bl
    mov cx,80
    mul cx
    shr bx,8
    add ax,bx
    mov cx,2
    mul cx
    mov bx,ax
    ret

SHOW:
    mov cl,'*'
    mov ch,[color]
    or ch,0xf0
    mov [es:bx],cx
    inc ch
    mov [color],ch
    ret


DELAY:
    push ax
    push cx

    mov cx,Delay
    OLOOP:
        mov ax,DDelay
        ILOOP:
            dec ax
            jg ILOOP
    loop OLOOP

    pop cx
    pop ax
    ret



DATA:
    ; Message: db '>> Hello, MyOs is loading user program C.COM...'
    ; MessageLength  equ ($-Message)
    Rolling: db 'rolling'
    Rlen equ ($-Rolling)
    Stone: db 'stone'
    Slen equ ($-Stone)
    pos dw 0x0c11   ;(x,y)
    dir dw 0x0101   ;(dx,dy)
    color db 0x00
    count db 0

times 512-($-$$) db 0
