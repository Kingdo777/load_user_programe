;用户程序
%include "stdvar.asm"
section head vstart=0 align=32
[bits 32]
;程序长度
program_len dd program_end
;入口地址
program_entry:
			dd start
			dw code_32_user
;用户程序各个段的汇编地址（用以重定位）
user_code_asm_addr:			dd	section.user_code.start
user_data_asm_addr:			dd 	section.user_data.start
;栈的大小分配有用户决定，用户只需要使用就可以了
head_end:
;----------------------------------代码段---------------------------------------------------
section user_code vstart=0 align=32
[bits 32]
start:;物理地址0x000000100020
;配置数据段
mov ax,data_32_user
mov ds,ax
;打印开场白
mov ah,0x04
mov ebx,string
mov esi,put_string_index
call system
;打印指定文件的内容
mov eax,test_file_position_in_disk
mov ebx,buffer
mov esi,read_disk_index
call system
mov byte [buffer+512],0
mov ah,0x04
mov ebx,buffer
mov esi,put_string_index
call system

;打印结束语
mov ah,0x04
mov ebx,string1
mov esi,put_string_index
call system
mov ah,0x04
mov ebx,string1
mov esi,put_string_index
call system 


hlt
;---系统调用函数-----------
%include "system.asm"
;----------------------------------数据段---------------------------------------------------
section user_data vstart=0 align=32
[bits 32]
string:  		db `Hello I am UserPrograme!\nI am Happy\n`,0
string1:  		db `Bye!`,0
buffer:			times 1024 db 0
section tail align=32
[bits 32]
program_end: