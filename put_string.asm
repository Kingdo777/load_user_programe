;打印字符串的相关的一系列函数
;输入：ah->高亮;[ds:ebx]->字符串地址（字符串必须以0结尾）
;输出：无
put_string:
mov al,[ebx]
cmp al,0
je _put_string_end
call put_char
inc ebx
jmp put_string
_put_string_end:
retf
;输入：ah->高亮;al->要输出的ascII
put_char:
push eax
push ebx
push ecx
push edx
push ds
push es
;记录当前光标位置
call read_cursor
movzx ebx,bx
cmp al,0x0a
je _put_char_wrap
cmp al,0x0d
je _put_char_wrap
shl ebx,1
mov [gs:ebx],ax
shr ebx,1
inc ebx
jmp _put_char_ifFull
_put_char_wrap:;换行
xor edx,edx
mov eax,ebx
mov ebx,80
div ebx
inc eax
mul ebx
mov ebx,eax
_put_char_ifFull:;判断是否满屏
cmp ebx,80*25
jnae _put_char_end
mov ebx,80*24
mov ax, data_show
mov ds,ax
mov es,ax
xor edi,edi
mov esi,80*2
mov ecx,24*80
rep movsw
mov ecx,80
_put_char_clear_last_line:
mov word [edi],0
add edi,2
loop _put_char_clear_last_line
_put_char_end:
call write_cursor
pop eax
mov es,ax
pop eax
mov ds,ax
pop edx
pop ecx
pop ebx
pop eax
ret
;读光标位置(结果保存到bx)
read_cursor:
push eax
push ecx
push edx
mov dx,0x3d4
mov al,0x0e
out dx,al
mov dx,0x3d5
in al,dx
mov ah,al
mov dx,0x3d4
mov al,0x0f
out dx,al
mov dx,0x3d5
in al,dx
mov bx,ax
pop edx
pop ecx
pop eax
ret
;写光标位置(位置保存在BX)
write_cursor:
push eax
push ebx
push ecx
push edx
mov dx,0x3d4
mov al,0x0e
out dx,al
mov dx,0x3d5
mov al,bh
out dx,al
mov dx,0x3d4
mov al,0x0f
out dx,al
mov dx,0x3d5
mov al,bl
out dx,al
pop edx
pop ecx
pop ebx
pop eax
ret