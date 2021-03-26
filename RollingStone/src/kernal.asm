BITS 16
global _start
global getchar
global CLS
global GetCursor
global SetCursor
global ReadFloopy_4par
global ShowChar
global ScrollUp
global userprgseg
global pro_end
; global CallUserPrg
extern main
extern proc_ptr
extern schedule

%macro writeIVT 3;(iseg,ioffset,vector)
    push es
    push ax
    xor ax,ax
    mov es,ax
    mov ax,%2
    mov word[es:%3*4],ax
    mov ax,%1
    mov word[es:%3*4+2],ax
    pop ax
    pop es
%endmacro

%macro prints 6;(r,c,seg,offset,len,color)
    push es
    push bp
    mov ax,%3
    mov es,ax
    mov bp,%4
    mov dh,%1
    mov dl,%2
    mov cx,%5
    mov bx,%6
    mov ax,0x1300;默认将属性放在bx中
    int 0x10
    pop bp
    pop es
%endmacro

%macro BCD2ASCII 2;(BCD,dstroffset)
    mov al,%1
    shr al,4
    mov ah,%1
    and ah,0x0f
    add ah,'0'
    add al,'0'
    mov word[%2],ax
%endmacro


_start:
    ; 设置时钟中断向量（08h），初始化段寄存器
    cli
    call Set_Timer
    mov ax,cs
    mov ds,ax
    mov bx,0x0000
    mov es,bx
    mov bx,0x08*4
    mov ax,word[es:bx]
    mov [time_int_off],ax
    mov ax,word[es:bx+2]
    mov [time_int_seg],ax

    mov ax,[userprgseg]

	writeIVT cs,Timer,0x08
    writeIVT cs,INT_22,0x22
    writeIVT cs,INT_20,0x20
    writeIVT cs,INT_21,0x21

    mov ax,cs
    mov ds,ax
    mov es,ax
    mov bx,ss
    mov ss,ax
    mov si,bp
    mov di,sp
    mov bp,0
    mov sp,0x0000
    mov word[ds:ker_ds],ds;保存内核数据段
    push bx
    push si
    push di;保存旧的栈段

    push word 0x0000;c生成的ret要32位的返回地址
    call main
    pop di
    pop si
    pop bx
    mov ss,bx
    mov bp,si
    mov sp,di;恢复旧的栈段
_end:
    jmp $

CLS:
    mov ax,0x0003
    int 0x10
    o32 ret;因为c调用压的是32位的返回地址，所以用32位返回，保证平栈

getchar:;阻塞的getchar
    mov ax,0x1000
    int 0x16
    o32 ret

ShowTime:
    push cx
    push dx

    mov ah,0x02
    int 0x1a
    BCD2ASCII ch,time
    BCD2ASCII cl,time+3
    BCD2ASCII dh,time+6
    
    mov ah,0x04
    int 0x1a
    BCD2ASCII ch,data
    BCD2ASCII cl,data+2
    BCD2ASCII dh,data+5
    BCD2ASCII dl,data+8

    prints 0x00,0x48,ds,time,tlen,0x0007
    prints 0x00,0x3c,ds,data,dlen,0x0007

    pop dx
    pop cx
    ret

GetCursor:
    push bx
    push dx
    mov ax,0x0300
    mov bx,0x0000
    int 0x10
    mov ax,dx
    pop dx
    pop bx
    o32 ret

SetCursor:;(r,c)
    push bp
    mov bp,sp
    push bx
    push dx
    mov ax,0x0200
    mov bx,0x0000
    mov dh,[bp+0x6]
    mov dl,[bp+0xa]
    int 0x10
    pop dx
    pop bx
    pop bp
    o32 ret

ReadFloopy_4par:;调用时候使用四个参数(c,h,s,num)
    push bp
    mov bp,sp
    push es
    push bx
    push cx
    push dx
    
    mov ax,[userprgseg]
    mov es,ax
    mov ah,0x02
    mov al,[bp+0x12];num
    mov bx,[userprgoffset]
    mov ch,[bp+0x6];c
    mov cl,[bp+0xe];s
    mov dh,[bp+0xa];h
    mov dl,0
    int 0x13

    pop dx
    pop cx
    pop bx
    pop es
    pop bp
    o32 ret

ShowChar:;(offset,char,color)
    push bp
    mov bp,sp
    push es
    push bx

    mov ax,0xb800
    mov es,ax
    mov bx,[bp+0x6]
    mov ah,[bp+0xe]
    mov al,[bp+0xa]
    mov [es:bx],ax

    pop bx
    pop es
    pop bp
    o32 ret

ScrollUp:;(num_r)
    push bp
    mov bp,sp
    push bx
    push cx
    push dx

    mov ah,0x06
    mov al,[bp+0x6]
    mov bx,0x0700
    mov cx,0x0000
    mov dx,0x184f
    int 0x10

    pop dx
    pop cx
    pop bx
    pop bp
    o32 ret

; CallUserPrg:
;     pusha
;     push ds
;     push es

;     mov ax,[userprgseg]
;     mov ds,ax
;     mov es,ax
;     mov bx,ss
;     mov ss,ax
;     mov si,bp
;     mov di,sp
;     mov bp,0
;     mov sp,0x0000;设置新的栈段
;     mov word[es:0x0000],0x20cd;在段首预埋int 20h的机器码
;     push bx
;     push si
;     push di;保存旧的栈段

;     push cs;返回段地址
;     push word retaddress;返回偏移量
;     push word 0x0000;ret后进入段首执行int 20h
;     jmp 0x2000:0x0100

;     retaddress:
;     pop di
;     pop si
;     pop bx
;     mov ss,bx
;     mov bp,si
;     mov sp,di;恢复旧的栈段

;     pop es
;     pop ds
;     popa
;     o32 ret

INT_22:
    call save
    prints 0x0c,0x24,ds,message,len,0x0007;(r,c,seg,offset,len,color)
    jmp restart

INT_21:
    call save
    mov bx,[time_int_seg]
    mov gs,bx
    mov bx,[time_int_off]
    writeIVT gs,bx,0x08;关闭时钟中断

    mov bp,[proc_ptr]
    mov ax,[ds:bp+10]
    mov bx,[ds:bp+12]
    mov cx,[ds:bp+14]
    mov es,[ds:bp+26];用es保存原来的ds以便跨段访问数据
    call syscall
    writeIVT cs,Timer,0x08;开启时钟中断
    jmp restart
INT_20:
    call save
    mov word[pro_end],0x0001
    push word 0x0000
    call schedule
    jmp restart;不会执行，只是保持结构
Set_Timer:
    mov al,34h			; 设控制字值
	out 43h,al				; 写控制字到控制字寄存器
	mov ax,1193182/20	; 每秒20次中断（50ms一次）
	out 40h,al				; 写计数器0的低字节
	mov al,ah				; AL=AH
	out 40h,al				; 写计数器0的高字节
    ret
Timer:
    call save
    ; push ax
    ; push ds
    ; push es
    mov ax,cs
    mov ds,ax
    mov ax,0xb800
    mov es,ax
	dec byte[count]				; 递减计数变量
	jnz end						; >0：跳转
    mov al,byte[bar]
    cmp al,'\'
    jnz @1
    mov al,'|' 
    jmp @4
    @1:
    cmp al,'|'
    jnz @2
    mov al,'/'
    jmp @4
    @2:
    cmp al,'/'
    jnz @3
    mov al,'-'
    jmp @4
    @3:
    cmp al,'-'
    jnz @4
    mov al,'\'
    @4:
    mov byte[bar],al
    mov ah,0x0f    
	mov [es:((24*80+79)*2)],ax		; =0：递增显示字符的ASCII码值
	mov byte[count],delay			; 重置计数变量=初值delay
    call ShowTime
    ; cli
    ; sti
end:
    push word 0x0000
    call schedule

    jmp restart
    ; pop es
    ; pop ds
    ; pop ax
    ; sti
	; iret							; 从中断返回


save:				; save the machine state in the	proc table.
	push ds			; stack: psw/cs/pc/ret addr/ds
    push bx
    mov bx,cs
    mov ds,bx
	; mov ds,[ker_ds]		; word 4 in kernel text	space contains ds value
    pop word[bx_save]
	pop word[ds_save]		; stack: psw/cs/pc/ret addr
	pop word[ret_save]		; stack: psw/cs/pc
	mov bx,[proc_ptr]	; start	save set up; make bx point to save area
	pop word[bx]		; store	pc in proc table
	pop word[bx+2]	; store	cs in proc table
	pop word[bx+4]		; store	psw
    mov word[sp_save],sp
    mov word[ss_save],ss
	mov word[bx+6],ss	; store	ss
	mov word[bx+8],sp	; sp as	it was prior to	interrupt
    add bx,28
	mov sp,bx		; now use sp to	point into proc	table/task save
	mov bx,ds		; about	to set ss
	mov ss,bx		; set ss
	push word[ds_save]		; start	saving all the registers, sp first
	push es			; save es between sp and bp
	push bp			; save bp
	push di			; save di
	push si			; save si
	push dx			; save dx
	push cx			; save cx
	push word[bx_save]		; save original	bx
	push ax				    ; all registers now	saved		    ; splimit checks for stack overflow
    mov sp,word[sp_save]
    mov ss,word[ss_save];使用触发中断的段的栈空间
	mov ax,[ret_save]		; ax = address to return to
	jmp ax			; return to caller; Note: sp points to saved ax

restart:
    mov bx,cs
    mov ds,bx
    mov ss,bx;PCB放在kernal段里
    mov bx,[proc_ptr]
    add bx,10
	mov sp,bx	; return to user, fetch	regs from proc table
	pop ax			; start	restoring registers
	pop bx			; restore bx
	pop cx			; restore cx
	pop dx			; restore dx
	pop si			; restore si
	pop di			; restore di
	pop bp			; restore bp
	pop es			; restore es
    pop word[ds_save]
    mov [bx_save],bx		; lds_low contains bx
	mov bx,[proc_ptr]		; bx points to saved ds	register
    add bx,8
	mov sp,[ds:bx]	; restore sp
	mov ss,[ds:bx-2]	; restore ss using the value of	ds
    
    cmp word[ds:bx-8],0x100
    jne r_end
    push word 0x0000
    mov word[ss:0x0000],0x20cd

    r_end:
	push word[ds:bx-4]	; push psw (flags)
	push word[ds:bx-6]	; push cs
	push word[ds:bx-8]	; push pc
    mov bx,[bx_save]
    mov ds,[ds_save]
    push ax
    mov al,20h					; AL = EOI
	out 20h,al						; 发送EOI到主8529A
	out 0A0h,al					; 发送EOI到从8529A
    pop ax
	iret			; return to user or task

syscall:
    cmp ax,0x3
    jnbe s_end

    cmp ax,0x0
    jg func1
    func0:
    call s_func0
    jmp s_end

    func1:
    cmp ax,0x1
    jg func2
    call s_func1
    jmp s_end
    
    func2:
    cmp ax,0x2
    jg func3
    call s_func2
    jmp s_end

    func3:
    call s_func3
    s_end:
    ret

compute_offset:;(位置放在ax传进来)
    push bx
    push cx
    push dx
    mov bx,ax
    xor ax,ax
    mov al,bh
    mov cx,80
    mul cx
    and bx,0x00ff
    add ax,bx
    mov cx,2
    mul cx
    pop dx
    pop cx
    pop bx
    ret
s_func0:
    push word 0x0000
    call GetCursor
    push ax;保存一下坐标
    call compute_offset
    push dword 0x07
    push ebx
    push eax
    push word 0x0000
    call ShowChar
    add sp,12
    pop ax
    inc ax
    push eax
    shr ax,8
    push eax
    push word 0x0000
    call SetCursor
    add sp,8
    ret
s_func1:;要不要回显
    push word 0x0000
    call getchar
    mov byte[es:bx],al
    ret
s_func2:;upper2lower
    func2_start:
    mov al,byte[es:bx]
    inc bx
    cmp al,'A'
    jb func2_end
    cmp al,'Z'
    jg func2_end
    add al,'a'-'A'
    mov byte[es:bx-1],al
    jmp func2_start
    func2_end:
    cmp al,0x00
    jnz func2_start
    ret
s_func3:
    push word 0x0000
    call GetCursor
    xor al,al
    push eax
    shr ax,8
    inc ax
    push eax
    push word 0x0000
    call SetCursor
    add sp,8
    push word 0x0000
    call GetCursor
    ret

Data:
	delay equ 4					; 计时器延迟计数
	count db delay					; 计时器计数变量，初值=delay
    userprgoffset dw 0x0100
    userprgseg dw 0x0000
    pro_end dw 0x0000;1代表结束，0代表运行
    bar db '/'
    message db 'INT22H'
    len equ ($-message)
    time db '00:00:00'
    tlen equ ($-time)
    data db '0000-00-00'
    dlen equ ($-data)

    ker_ds dw 0
    ds_save dw 0
    ret_save dw 0
    bx_save dw 0
    sp_save dw 0
    ss_save dw 0

    pos dw 0

    time_int_seg dw 0
    time_int_off dw 0 

    
