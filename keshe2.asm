assume cs:code

code segment
     
	  star:call re9
	  
	       mov ax,0
		   mov es,ax
		   mov bx,7e00h
		   
		   mov al,10
		   mov ch,0
		   mov cl,1
		   mov dl,0
		   mov dh,0
		   
		   mov ah,2
		   int 13h
		   
		   mov bx,0
		   push bx
		   mov ax,7e00h
		   mov bx,offset star1 - offset star
		   add ax,bx
		   push ax
		   
		   retf	   
		   
     star1:jmp short ok
	  
	    ag1 db '1) reset pc'
		
		ag2 db '2) start system'
		
		ag3 db '3) clock'
		
		ag4 db '4) set clock'
		
		ok:call re5
		   
		   
		s5:in al,60h
		   cmp al,02h
		   je ok41
		   cmp al,03h
		   je ok42
		   cmp al,04h
		   je ok43
		   cmp al,05h
		   je ok44
		   jmp short s5
		     
	  ok41:call re1
		   jmp short s5
	  ok42:call re2
		   jmp short s5
	  ok43:call re3
		   jmp short s5
	  ok44:call re4
		   jmp short s5
		   
		   
	   re1:jmp short s6
	   
	 table db 'Rstart Pc',0
	 
        s6:mov si,0 
		   mov di,0
		   mov dh,00000100b
		   
        s7:mov al,table[07e00h+si]
		   cmp al,0
		   je restart
	       mov es:[160*16+60+di],al
	       mov es:[160*16+60+1+di],dh
		   inc si
		   add di,2
		   jmp short s7
		   
   restart:mov bx,0ffffh
           push bx
		   mov bx,0
		   push bx
		   
		   retf 
		   ret
		   
		   
	   re2:jmp short s8
	   
	   table1 db 'Start C System'
	   
	    s8:mov si,0 
		   mov di,0
		   mov dh,00000100b
		   
        s9:mov al,table1[07e00h+si]
		   cmp al,0
		   je restartone
		   mov es:[160*16+60+1+di],dh
	       mov es:[160*16+60+di],al
		   inc si
		   add di,2
		   jmp short s9
		   
restartone:mov ax,0
		   mov es,ax
		   mov bx,07c00h
		   
		   mov al,1
		   mov ch,0
		   mov cl,1
		   mov dh,0
		   mov dl,80h
		   
		   mov ah,2
		   int 13h
		   
		   mov bx,0
           push bx
		   mov bx,07c00h
		   push bx
		   
		   retf 
		   ret
		   
		   
	   re3:call re7
		    
	       mov dh,00000100b
		   
	   s10:call re6
	   
	   
		   in al,60h 
		   cmp al,3bh
		   je ok4
		   cmp al,01h
		   je ok5
		   
	       jmp near ptr s10   
		   
	   ok5:push di
	       push cx   
	       push dx
		   mov di,0
		   mov dh,0
		   mov cx,17
     clear:mov byte ptr es:[160*7+60+di+1],dh
		   add di,2
		   loop clear
		   pop dx
		   pop cx
		   pop di
		   
		   call re5
		   
	       ret
		   
	   ok4:inc dh
	       jmp near ptr s10 
		   
		   
	   re4:
	       call re7
		   call re6

	       mov ax,0
		   mov ds,ax
		   mov si,09c00h
		   
	getstr:push ax
		   
   getstrs:mov ah,0
		   int 16h
		   
		   cmp ah,0eh
		   je backspace
		   cmp ah,1ch
		   je enter1
		   
		   cmp al,'0'
		   jb getstrs
		   cmp al,'9'
		   ja getstrs
		   
		   mov ah,0
		   call charstack
		   mov ah,2
		   call charstack
		   jmp getstrs
		   
 backspace:mov ah,1
		   call charstack
		   mov ah,2
		   call charstack
		   jmp getstrs
		   
	enter1:mov al,0
		   mov ah,0
		   call charstack
		   mov ah,2
		   call charstack
		   pop ax
		   
		   push di
	       push cx   
	       push dx
		   mov di,0
		   mov dh,0
		   mov cx,17
    clear1:mov byte ptr es:[160*7+60+di+1],dh
		   add di,2
		   loop clear1
		   pop dx
		   pop cx
		   pop di
		   call re7
		   call re5
		   
		   ret
		   
		   
 charstack:jmp short charstart

		   table3 dw charpush+07e00h,charpop+07e00h,charshow+07e00h
		   
       	     top dw 0

 charstart:push bx
		   push dx
		   push di
		   push es
		   
		   cmp ah,2
		   ja ok9
		   mov bl,ah
		   mov bh,0       
		   add bx,bx
		   jmp word ptr table3[07e00h+bx]
		
       ok9:jmp near ptr sret		
	   
  charpush:mov bx,top[7e00h]
		   mov [si][bx],al
		   inc top[7e00h]
		   jmp sret
		   
   charpop:cmp top[7e00h],0
		   je sret
		   dec top[7e00h]
		   mov bx,top[7e00h]
		   mov al,[si][bx]
		   jmp sret
		   
  charshow:mov bx,0B800h
		   mov es,bx
		   mov di,0
		   mov bx,0
		   
 charshows:cmp bx,top[7e00h]
		   jne noempty
		   jmp sret
		   
   noempty:mov al,es:[160*7+60+di]
           cmp al,'/'
		   je ok6
		   
		   mov al,es:[160*7+60+di]
		   cmp al,':'
		   je ok6
		   
		   mov al,es:[160*7+60+di]
		   cmp al,' '
		   je ok6
		   mov al,[si][bx]
		   mov es:[160*7+60+di],al 
		   
		   
		   cmp di,32
		   je ok7
		   inc bx
		   add di,2
	   s12:jmp charshows
	   
	   ok7:call re8
	   s13:call re6
	   
	       
	      
		   in al,60h
		   cmp al,01ch
		   je ok8
		   jmp short s13
		   
	  sret:pop es
		   pop di
		   pop dx
		   pop bx
		   ret
		   
	   ok6:add di,2
		   jmp short s12
		   
	   ok8:push di
	       push cx   
	       push dx
		   mov di,0
		   mov dh,0
		   mov cx,17
    clear2:mov byte ptr es:[160*7+60+di+1],dh
		   add di,2
		   loop clear2
		   pop dx
		   pop cx
		   pop di
		   
		   call re5
	       jmp near ptr s5  
		 
		   
	   re5:push ax
		   push dx
		   push cx
		   push si
		   push di
	       mov ax,0B800h
		   mov es,ax
		   mov dh,03h
		   mov si,0
		   mov di,0
		   mov cx,11
		    
		s1:mov dl,ag1[07e00h+si]
		   mov es:[160*10+60+1+di],dh
		   mov es:[160*10+60+di],dl
		   add di,2
		   inc si
		   loop s1
		   
		   mov si,0
		   mov di,0
		   mov cx,15
		     
		s2:mov dl,ag2[07e00h+si]
		   mov es:[160*11+60+1+di],dh
		   mov es:[160*11+60+di],dl
		   add di,2
		   inc si
		   loop s2
		   
		   mov si,0
		   mov di,0
		   mov cx,8
		   
		s3:mov dl,ag3[07e00h+si]
		   mov es:[160*12+60+1+di],dh
		   mov es:[160*12+60+di],dl
		   add di,2
		   inc si
		   loop s3
		   
		   mov si,0
		   mov di,0
		   mov cx,12
		   
		s4:mov dl,ag4[07e00h+si]
		   mov es:[160*13+60+1+di],dh
		   mov es:[160*13+60+di],dl
		   add di,2
		   inc si
		   loop s4
		   pop di
		   pop si
		   pop cx
		   pop dx
		   pop dx
		   
		   ret
		   
		   
	   re6:push ax
		   push dx
		   push cx
		   inc dh
	       mov dl,'/'
	       mov al,9
		   out 70h,al
		   in al,71h
		   
		   mov ah,al
		   mov cl,4
		   shr ah,cl
		   and al,00001111b
		   
		   add ah,30h
		   add al,30h
		
		   mov byte ptr es:[160*7+60+1],dh
		   mov byte ptr es:[160*7+60],ah
		   mov byte ptr es:[160*7+60+2+1],dh
		   mov byte ptr es:[160*7+60+2],al
		
		   mov byte ptr es:[160*7+60+4+1],dh
		   mov byte ptr es:[160*7+60+4],dl
		   
		   mov al,8
		   out 70h,al
		   in al,71h
		   
		   mov ah,al
		   mov cl,4
		   shr ah,cl
		   and al,00001111b
		   
		   add ah,30h
		   add al,30h
		   
		   mov byte ptr es:[160*7+60+6+1],dh
		   mov byte ptr es:[160*7+60+6],ah
           mov byte ptr es:[160*7+60+8+1],dh
		   mov byte ptr es:[160*7+60+8],al 
		 
		   mov byte ptr es:[160*7+60+10+1],dh
		   mov byte ptr es:[160*7+60+10],dl
		   
		   
		   mov al,7
		   out 70h,al
		   in al,71h
		   
		   mov ah,al
		   mov cl,4
		   shr ah,cl
		   and al,00001111b
		   
		   add ah,30h
		   add al,30h
	
	       mov byte ptr es:[160*7+60+12+1],dh
		   mov byte ptr es:[160*7+60+12],ah
		   mov byte ptr es:[160*7+60+14+1],dh
		   mov byte ptr es:[160*7+60+14],al
		   
		   
		   mov dl,' '
		   mov byte ptr es:[160*7+60+16+1],dh
		   mov byte ptr es:[160*7+60+16],dl
		  
		   
		   mov al,4
		   out 70h,al
		   in al,71h
		   
		   mov ah,al
		   mov cl,4
		   shr ah,cl
		   and al,00001111b
		   
		   add ah,30h
		   add al,30h
		   
		   mov byte ptr es:[160*7+60+18+1],dh
		   mov byte ptr es:[160*7+60+18],ah
		   mov byte ptr es:[160*7+60+20+1],dh
		   mov byte ptr es:[160*7+60+20],al
		  
		   
		   mov dl,':'
		   mov byte ptr es:[160*7+60+22+1],dh
		   mov byte ptr es:[160*7+60+22],dl
		 
		   
		   mov al,2
		   out 70h,al
		   in al,71h
		   
		   mov ah,al
		   mov cl,4
		   shr ah,cl
		   and al,00001111b
		   
		   add ah,30h
		   add al,30h
		  
		   mov byte ptr es:[160*7+60+24+1],dh
		   mov byte ptr es:[160*7+60+24],ah
		   mov byte ptr es:[160*7+60+26+1],dh
		   mov byte ptr es:[160*7+60+26],al
		   
		   
		   mov dl,':'
		   mov byte ptr es:[160*7+60+28+1],dh
		   mov byte ptr es:[160*7+60+28],dl
		 
		   
		   mov al,0
		   out 70h,al
		   in al,71h
		   
		   mov ah,al
		   mov cl,4
		   shr ah,cl
		   and al,00001111b
		   
		   add ah,30h
		   add al,30h
		   
		   mov byte ptr es:[160*7+60+30+1],dh
		   mov byte ptr es:[160*7+60+30],ah
		   mov byte ptr es:[160*7+60+32+1],dh
		   mov byte ptr es:[160*7+60+32],al
		   pop cx
		   pop dx
		   pop ax
		   
		   ret
		   
	   re7:push cx
	       push dx
		   push di
	       mov dl,0
		   mov di,0
	       mov cx,2000
	   s11:mov es:[1+di],dl
		   add di,2
	       loop s11
		   pop di
		   pop dx
		   pop cx
		   
		   ret
	 
	   re8:mov di,0
	       mov al,9
		   out 70h,al
		   mov al,es:[160*7+60+di]
		   sub al,30h
		   push dx
		   mov dl,10
		   mul dl
		   pop dx
		   add di,2
		   push dx
		   mov dl,es:[160*7+60+di]
		   sub dl,30h
		   add al,dl
		   pop dx
		   out 71h,al
		   
		   mov di,6
	       mov al,8
		   out 70h,al
		   mov al,es:[160*7+60+di]
		   sub al,30h
		   push dx
		   mov dl,10
		   mul dl
		   pop dx
		   add di,2
		   push dx
		   mov dl,es:[160*7+60+di]
		   sub dl,30h
		   add al,dl
		   pop dx
		   out 71h,al
		   
		   mov di,12
	       mov al,7
		   out 70h,al
		   mov al,es:[160*7+60+di]
		   sub al,30h
		   push dx
		   mov dl,10
		   mul dl
		   pop dx
		   add di,2
		   push dx
		   mov dl,es:[160*7+60+di]
		   sub dl,30h
		   add al,dl
		   pop dx
		   out 71h,al
		   
		   mov di,18
	       mov al,4
		   out 70h,al
		   mov al,es:[160*7+60+di]
		   sub al,30h
		   push dx
		   mov dl,10
		   mul dl
		   pop dx
		   add di,2
		   push dx
		   mov dl,es:[160*7+60+di]
		   sub dl,30h
		   add al,dl
		   pop dx
		   out 71h,al
		   
		   mov di,24
	       mov al,2
		   out 70h,al
		   mov al,es:[160*7+60+di]
		   sub al,30h
		   push dx
		   mov dl,10
		   mul dl
		   pop dx
		   add di,2
		   push dx
		   mov dl,es:[160*7+60+di]
		   sub dl,30h
		   add al,dl
		   pop dx
		   out 71h,al
		   
		   mov di,30
	       mov al,0
		   out 70h,al
		   mov al,es:[160*7+60+di]
		   sub al,30h
		   push dx
		   mov dl,10
		   mul dl
		   pop dx
		   add di,2
		   push dx
		   mov dl,es:[160*7+60+di]
		   sub dl,30h
		   add al,dl
		   pop dx
		   out 71h,al
		   
		   ret
		   
	   re9:mov ax,cs
		   mov ds,ax
		   
		   mov ax,0
		   mov es,ax
		   
		   mov si,07e00h+offset int9
		   mov di,204h
		   mov cx,offset int9end - offset int9
		   cld
		   rep movsb
		   
		   push es:[9*4]
		   pop es:[200h]
		   push es:[9*4+2]
		   pop es:[202h]
		   
		   cli
		   mov word ptr es:[9*4],204h
		   mov word ptr es:[9*4+2],0
		   sti

		   ret
		 		   
	  int9:push ax
		   push bx
		   push cx
		   push es
		   
           
		   
           pop es
	       pop cx
		   pop bx
		   pop ax
		   
		   iret
	  
   int9end:nop	
		   
		 		   
		
		 
	 start:mov ax,code
	       mov es,ax
		   mov bx,0
		   
	       mov al,10
	       mov ch,0
		   mov cl,1
		   mov dl,0
		   mov dh,0
		   
		   mov ah,3
		   int 13h
		   
		   mov ax,4c00h
		   int 21h
		   
code ends

end start