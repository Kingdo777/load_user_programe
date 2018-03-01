;内核代码
%include "stdvar.asm"
section head vstart=0 align=32
[bits 32]
;程序长度
program_len dd program_end
;入口地址
program_entry:
			dd start
			dw code_32_core
;内核程序各个段的汇编地址（用以重定位）
core_code_asm_addr:			dd	section.core_code.start
core_data_asm_addr:			dd 	section.core_data.start
core_stack_asm_addr:		dd 	stack_end;此处给出的应该是栈的高地址而不是低地址
core_library_code_asm_addr:	dd	section.core_library_code.start
head_end:
;----------------------------------代码段---------------------------------------------------
section core_code vstart=0 align=32
[bits 32]
start:;此处的物理地址是0x000000017e20
;重新分配段寄存器
mov ax,data_32_core
mov ds,ax
mov ax,stack_32_core
mov ss,ax
xor esp,esp
mov ax,data_show
mov gs,ax
mov ax,data_4g
mov es,ax
;存放gdt
sgdt [gdt];此处的物理地址是0x000000017e3a
;预创建用户段（数据段、堆栈段、代码段）
xor eax,eax
xor ebx,ebx
xor ecx,ecx
times 3 call code_32_core_library:make_gdt
lgdt [gdt]
;加载用户程序
mov eax,user_program_position_in_disk
call load_user_programe
hlt
;---------------内核的内置函数-----------------------
%include "load_user_programe.asm"
core_code_end:
;----------------------------------数据段---------------------------------------------------
section core_data vstart=0 align=32
[bits 32]
string1: 		db `\nHello World\nMy Name Is ZXM!\n`,0
function_offset_table:
				dd trap
				dw code_32_core_library
				dd put_string
				dw code_32_core_library
				dd read_hard_disk
				dw code_32_core_library
				dd make_gdt
				dw code_32_core_library
				dd update_gdt
				dw code_32_core_library
;保存内核的esp
store_esp:		dd 0
;保存用户程序的ss和esp
user_store_ss:		dw 0
user_store_esp:		dd 0
free_mem_addr:	dd user_program_load_position;这里用于存放当前可用的内存，已分配给用户，此内存是向上分配的且不回收（反正也用不完）
gdt:
	gdt_size:	dw 0
	gdt_addr:	dd 0
stack_start:
times 4*1024 	db 0
stack_end:
core_data_end:
;----------------------------------例程代码段---------------------------------------------------
section core_library_code vstart=0 align=32
[bits 32]
core_library_code:;选择子：code_32_core_library
;--------类陷入指令-----------------------------------------------------------------------------
%include "trap.asm"
;--------打印字符串-----------------------------------------------------------------------------
%include "put_string.asm"
;--------读磁盘-----------------------------------------------------------------------------
%include "read_disk.asm"
;--------写一个段描述符表-----------------------------------------------------------------------------
%include "make_gdt.asm"
;--------更新一个段描述符表-----------------------------------------------------------------------------
%include "update_gdt.asm"
;-------------------------------------------------------------------------------------
core_library_code_end:
section tail align=32
[bits 32]
program_end: