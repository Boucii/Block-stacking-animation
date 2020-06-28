;------------------------------------------------
;--------------砖块堆叠动画----------------------
;---------------------计科1805---Qinys 制作-----
;请将dos窗口设置为80*25的显示大小以获得正确的体验
;-------------输入大写S以开始程序-----------------
;------------------------------------------------

    assume cs:code,ss:stack,ds:data
;-----------------------------------------数据段
data segment
        db '|______|'                     ;一块砖
        ;db 00000010B
        db 00100100B
        db 01110001B
        db 00100100B
        db 11111001B                      ;4种不同的配色方案
        db 'Welcome to Block Build!'
        db 'Created by QinYongsheng'
        db '---Press S to start----'
        db '--Press Anykey to stop-'      ;问候语
data ends
;-----------------------------------------堆栈段
stack segment
        db 128 dup (0)
stack ends
;-----------------------------------------
code segment
;==========================================主程序
 start: mov ax,stack
        mov ss,ax
        mov sp,128

        mov ax,data                        ;数据段基地址放入ds
        mov ds,ax
 ;------------------------------------------清屏（清除dos界面的指令）
        mov ax,3h
        int 10h 
 ;------------------------------------------显示问候语             
        call show_title
;------------------------------------------输入s以开始   
input:   mov ah,1
         int 21h  
         cmp al,'S'
         jne input
               
;------------------------------------------清屏（清除问候语）
        mov ax,3h
        int 10h
;-------------------------------------------开始画图       
        call build
        
next: 
        mov ax,4c00h
        int 21h
;=============================================主程序结束
show_title proc near           ;问候语的子程序

        mov bx,0b800h         ;显存的基地址存到es
        mov es,bx
        mov si,12             ;问候词的起始位置

        mov bx,8              ;配色方案的起始位置
        mov di,12*160+56      ;开始写的显存位置

        mov cx,4               ;四行问候语

nextgreet:   
        push cx
        push di

                      
        mov cx,23              ;问候词字符串的长度是23


putchar:   
        mov dl,ds:[si]           ;ds:[si]里是待写的字符
        mov dh,ds:[bx]           ;ds:[bx]里是配色方案
        mov es:[di],dx           ; es:[di]  字符与颜色，写到显存
        inc si                   ;下一个字符
        add di,2                 ;下一个待写的显存位置
        loop putchar

        pop di
        pop cx
        inc bx
        add di,160                ;换下一行写
        loop nextgreet

        
        
        ret
        show_title endp
;-------------------------------------
build proc near                   ;搭建砖块的子程序

        mov bx,0b800h           ;显存的基地址存到es
        mov es,bx

        mov bx,8             ;配色方案的起始位置
        mov di,24*160      ;开始写的显存位置
        mov cx,23             ;总共擂23行
 ch_row:push cx       
        mov cx,5                 ;一行放5快砖
        
 re:    push cx
        mov cx,2                ;两块砖的时候配色方案重新开始循环

writeblock:
        push cx
        ;push di

        mov si,0              ; 砖块字符串的开始地址
        mov cx,8              ;一块砖有8个字符


writeletter:   
        mov dl,ds:[si]           ;ds:[si]里是待写的字符
        mov dh,ds:[bx]            ;ds:[bx]里是配色方案
        mov es:[di],dx             ; es:[di]  字符与颜色，写到显存
        inc si                     ;下一个字符
        add di,2                  ;下一个待写的显存位置
        loop writeletter
        
        
;-------------------------------------延时和判断是否有字符输入了
        call delay
        mov ah,01h
        int 16h
        jnz next                       ;有字符输入则回到next
;-------------------------------------

        ;pop di
        pop cx
        inc bx
        ;add di,16                      ;因为push了di，下一个写的显存位置/已废弃
        loop writeblock
        
        pop cx
        sub bx,2
        loop re
        
        pop cx
        sub di,2*160                    ;这一行铺满了砖，写上一行
        inc bx                          ;换配色方案，使得两行之间的配色方案可以交错
        cmp bx,10                       ;换配色方案，使得两行之间的配色方案可以交错
        jne continue                    ;换配色方案，使得两行之间的配色方案可以交错
        sub bx,2                        ;换配色方案，使得两行之间的配色方案可以交错
        
continue:
        loop ch_row
        jmp next
        
        ret
        build endp
;------------------------------------延时子程序
delay proc near
        push cx
        push dx
        push ax
        
        mov cx, 0007h
        mov dx, 0A120h     ;cx:dx是延迟的微秒，现在的方案是0.5秒 16进制字母开头加0
        mov ax, 0
        mov ah, 86h

        int 15h           ;中断调用
        
        pop ax
        pop dx
        pop cx
ret
delay endp

code ends

end start