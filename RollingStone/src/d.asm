	
    Delay equ 50000
    DDelay equ 1000

    Max_X equ 79
    Min_X equ 40
    Max_Y equ 24
    Min_Y equ 13


	org 0x100

;第一个参数是字符,第二个参数是地址
%macro SHOW 2 
    mov cl,%1
    mov ch,[color]
    mov bx,%2
    mov [es:bx],cx
%endmacro
;将第二个参数赋值给第一个参数
%macro ASSIGN 2 
    mov ax,%2
    mov %1,ax
%endmacro
    
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
    call Print_Id
    ; call Read_Char
    ; cmp ax,0x2e03
    ; je  return
    dec byte[count]
    jz return
    call DELAY
    call UPDATA
	jmp START  

return:
    ret

Read_Char:;从键盘读一个字符保存到ax（ah->打印，al->ascii）中，没有则置0
      mov ah,0x01
      int 0x16
      jnz s
      mov ax,0
      jmp end
      s:
      mov ah,0x00
      int 0x16
      end:
      ret

Print_Id:
    SHOW '1',[Address1]
    SHOW '8',[Address2]
    SHOW '3',[Address3]
    SHOW '4',[Address4]
    SHOW '0',[Address5]
    SHOW '1',[Address6]
    SHOW '7',[Address7]
    SHOW '3',[Address8]
    ret

ADDRESS:
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

    SHOW ' ',[Address1]
    call ADDRESS
    ASSIGN [Address1],[Address2]
    ASSIGN [Address2],[Address3]
    ASSIGN [Address3],[Address4]
    ASSIGN [Address4],[Address5]
    ASSIGN [Address5],[Address6]
    ASSIGN [Address6],[Address7]
    ASSIGN [Address7],[Address8]
    ASSIGN [Address8],bx
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
    ; Message: db '>> Hello, MyOs is loading user program D.COM...'
    ; MessageLength  equ ($-Message)
    Address1 dw 0x0870   
    Address2 dw 0x0912
    Address3 dw 0x09b4
    Address4 dw 0x0a56
    Address5 dw 0x0af8
    Address6 dw 0x0b9a
    Address7 dw 0x0c3c
    Address8 dw 0x0cde
    pos dw 0x2f14
    dir dw 0x0101   ;(dx,dy)
    color db 0x3d
    count db 0
times 512-($-$$) db 0
