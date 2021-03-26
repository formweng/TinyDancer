	
    Delay equ 50000
    DDelay equ 1000

    Max_X equ 39
    Min_X equ 0
    Max_Y equ 12
    Min_Y equ 1


	org 0x0100
    ; push di
    ; mov di,bp

    ; mov bp, Message		 	; BP=当前串的偏移地址
	; mov ax, ds		       	; ES:BP = 串地址
	; mov es, ax		       	; 置ES=DS
	; mov cx, MessageLength   ; CX = 串长（=9）
	; mov ax, 0x1301		 	; AH = 13h（功能号）、AL = 01h（光标置于串尾）
	; mov bx, 0x0007		 	; 页号为0(BH = 0) 黑底白字(BL = 07h)
    ; mov dh, 0		       	; 行号=0
	; mov dl, 0			 	; 列号=0
	; int 0x10			 	; BIOS的10h功能：显示一行字符

    ; mov bp,di
    ; pop di
    mov ax,0xb800
	mov es,ax
    mov byte[count],0xff

START:
    ; int 0x08 
    call ROLLING
    call DELAY
    ; call Read_Char
    ; cmp ax,0x2e03
    ; je  return
    dec byte[count]
    jne START
return:
    ret

; Read_Char:;从键盘读一个字符保存到ax（ah->打印，al->ascii）中，没有则置0
;       mov ah,0x01
;       int 0x16
;       jnz s
;       mov ax,0
;       jmp end
;       s:
;       mov ah,0x00
;       int 0x16
;       end:
;       ret

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
    cmp ah,Min_X
    jg  @X1
    mov bh,1
@X1:
    cmp ah,Max_X
    jl  @X2
    mov bh,-1
@X2:
    cmp al,Min_Y
    jg @Y1
    mov bl,1
@Y1:
    cmp al,Max_Y
    jl  @Y2
    mov bl,-1
@Y2:
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
    mov cl,[char]
    mov ch,[color]
    mov [es:bx],cx
    inc cl
    inc ch
    cmp cl,'Z'
    jle @1
    mov cl,'A'
    @1:
    cmp ch,15
    jle @2
    mov ch,2
    @2:
    mov [char],cl
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
    ; Message: db '>> Hello, MyOs is loading user program A.COM...'
    ; MessageLength  equ ($-Message)
    pos dw 0x0001   ;(x,y)
    dir dw 0x0101   ;(dx,dy)
    char db 'A'
    color db 2
    count db 0

times 512-($-$$) db 0
