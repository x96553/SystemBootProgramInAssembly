assume cs:codesg

data segment

		db '1975','1976','1977','1978','1979','1980','1981','1982','1983'           ;1.输入年份
		db '1984','1985','1986','1987','1988','1989','1990','1991','1992'           ;2.输入收入
		db '1993','1994','1995'														;3.输入人数
		;以上是表示21年的21个字符串													;4.计算人均
		
		dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
		dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
		;以上是表示21年公司总收入的21个dword数据
		
		dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
		dw 11542,14430,15257,17800
		;以上表示21年公司雇员的21个word型数据
	
data ends

table segment

		db 21 dup ('year',0,'summ me ?? ') 
	
table ends

stack segment

		dw 100 dup (0)  ; 栈段的设置  
	
stack ends
string segment

		dw 16 dup (0)   ; 后面的不会溢出的除法输入到显存所需的空间

codesg segment

start:	mov ax,data     ;先写如何输入年份，后再考虑其他
		mov ds,ax
		mov ax,table
		mov es,ax
		mov ax,stack
		mov ss,ax
		mov sp,100
		mov bx,0
		mov bp,0
		
		mov cx,21
	s0: push cx
	    mov si,0
		mov cx,4
		
	s:  mov al, [bx+si]
		mov es:[bp+si],al
		inc si
		loop s
		
		add bp,10h
		add bx,4
		pop cx
		loop s0           ;到这里年份算是输入完了，然后考虑输入收入
		
		mov cx,21
		mov bp,5
	s1:	mov si,0
		mov ax,[bx+si]
		add si,2
		mov dx,[bx+si]
	    mov es:[bp],ax
		mov es:[bp+2],dx   ; 这里也算是完成了，但注意读数要从高位到低位
		add bp,10h
		add bx,4
		loop s1		       ;现在要做的就是输入人数，最后计算平均值，先以同样方法输入（其实想可不可以用栈呢,好像有点麻烦）
		
		mov cx,21
		mov bp,10
	s2:	mov ax,[bx]
		mov es:[bp],ax
		add bp,10h
		add bx,2           ;到这里人数也输入进来了，最后的处理就是用收入除以人数了，算出人均收入 放入D ,E两个字节中（取商吗？）
		loop s2
		
		mov cx,21
		mov bp,13
		mov bx,5
		mov si,10
	s3: mov ax,es:[bx]
	    mov dx,es:[bx+2]
		div word ptr es:[si]
		mov es:[bp],ax
		add bp,10h          ;首要先完成目的 后面再做优化
		add bx,10h
		add si,10h
		loop s3
		
	;..................................................................................	
	; 这里开始打印
	        mov si,0
	        mov dh,8
			mov dl,0
			mov ax,table
			mov ds,ax
	        mov cx,21
			
	show_s0:push cx
	        mov cx,0 
	        mov cl,2			            ;先尝试将年份输出来,			
			call show_tr			;输出完毕，再尝试将收入输出来，这应该也是最难的部分了
			add dh,1
			add si,12
			pop cx
			loop show_s0
			
			mov si,5
			mov cx,21
			mov dh,8
			mov dl,5
			
			mov bx,table
			mov es,bx
			mov bx,string 
			mov ds,bx
			
	show_s1:push cx
	        push dx
			mov cx,0
	        mov cl,2
			mov ax,es:[si]
			add si,2
			mov dx,es:[si]    ;这里是关于收入的输出，应该是本课程设计最难的地方：除法溢出的解决及十进制字符串化
			add si,2
			call dtocdw
			pop dx
			call show_str
			add dh,1
			add si,12
			pop cx
			loop show_s1
			
			mov si,10
			mov cx,21
			mov dh,8
			mov dl,14
			
			mov bx,table
			mov es,bx
			mov bx,string
			mov ds,bx
			
			
	show_s2:push cx
			push dx
			mov cx,0
			mov cl,2
			mov ax,es:[si]
			add si,1
			call dtoc
			pop dx
			call show_str
			add dh,1
			add si,15
			pop cx
			loop show_s2
			
			mov si,13
			mov cx,21
			mov dh,8
			mov dl,20
			
			mov bx,table
			mov es,bx
			mov bx,string
			mov ds,bx
			
    show_s3:push cx
			push dx
			mov cx,0
			mov cl,2
			mov ax,es:[si]
			add si,1
			call dtoc
			pop dx
			call show_str
			add dh,1
			add si,15
			pop cx
			loop show_s3
			
			
			
			
			
			
			
		
		mov ax,4c00h
		int 21h
		
show_str:push es
		 push cx
		 push dx 
		 push si
		 push ds
		 mov ax,0b800h    ;显存
         mov es,ax
         mov si,ds:[14]         ;保存主程序的寄存器中的数据【反序】
		 mov bx,0
		 mov di,0
		 mov al,160
		 mov bl,dh         
		 mul bl
		 mov bx,ax        ;找到所显示的位置
		 add dl,dl
		 add bl,dl
		 mov ah,cl
		 
	s4:  mov cl,ds:[si]
         mov ch,0
         jcxz ok              ;判断
         mov al,ds:[si]
         mov es:[bx+di],al
		 mov es:[bx+di+1],ah   ;写入显存  di的问题
		 add di,2
		 dec si        ;倒着输进显存
		 loop s4
	 ok: pop ds
	     pop si
	     pop dx
		 pop cx
		 pop es     ;取回原值并返回
	     ret
		 

;除法子程序，没有溢出的十进制转换
;名称：dtoc
;功能：将dword型数转换成十进制字符串，
;参数：ax=dword的低16位
;dx=dword的高16位
;ds:si指向字符串的首地址
divdw: push ax          ;这部分是不会溢出的除法
       mov ax,dx
	   mov dx,0
	   div bx           ;商保存在ax中，余数保存在dx中      
	   mov cx,dx        
	   mov dx,ax        ; dx:商  cx:余
	   pop ax
       push dx 
       mov dx,cx       ;商入栈  
       div bx 
	   mov cx,dx
	   pop dx         ;商取回  dx:高商 ax:低商 cx:余
	   ret

dtocdw:   
        push bx            ;这部分是将数据在计算机中可以转换成十进制输出【不会溢出的除法】
		push cx
		push dx
		push es
		push si
		push ax
		
		mov si,0
		mov ax,0
		mov ds:[si],ax
		pop ax
		push ax
		inc si
		mov bx,10		;商ax，余dx
	s5: call divdw
		add cx,30h
		mov ds:[si],cx
		mov cx,ax
		jcxz stop1
		inc si
		inc cx
		loop s5
		
stop1:	mov ds:[14],si
        
        pop ax
		pop si
		pop es
		pop dx
        pop cx
		pop bx
		ret
		
dtoc:   push si
        push bx            ;这部分是将数据在计算机中可以转换成十进制输出【一般】
		push cx
		push ds
		push dx
		push ax
		mov si,0
		mov ax,0
		mov ds:[si],ax
		pop ax
		push ax
		inc si
		mov bx,10              ;商ax，余dx
	s6:	mov dx,0
	    div bx
		mov cx,ax
		add dx,30h
		mov ds:[si],dx
		jcxz stop
		inc si
		inc cx
		loop s6
		
stop:   mov ds:[14],si
        pop ax
		pop dx
		pop ds
		pop cx
		pop bx
		pop si
		ret

show_tr: push es
		 push cx
		 push dx          
		 mov ax,0b800h    ;显存          这部分是向显存写入数据并表示【正序】
         mov es,ax
		                      ;保存主程序的寄存器中的数据
		 mov bx,0
		 mov di,0
		 mov al,160
		 mov bl,dh         
		 mul bl
		 mov bx,ax        ;找到所显示的位置
		 add dl,dl
		 add bl,dl
		 mov ah,cl
		 
	s11: mov cl,ds:[si]
         mov ch,0
         jcxz ok2              ;判断
         mov al,ds:[si]
         mov es:[bx+di],al
		 mov es:[bx+di+1],ah   ;写入显存
		 add di,2
		 inc si
		 loop s11
	 ok2:
	     pop dx
		 pop cx	
		 pop es     ;取回原值并返回
	     ret	
codesg ends

end start
     