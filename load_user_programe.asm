;加载用户程序，这是内核的一个内置函数，不是例程函数
load_user_programe:
;参数：eax-->用户程序的起始磁盘号
push ebx
push ecx
push edx
push esi
;1、把用户程序加载到内存
mov esi,[free_mem_addr]
push ds
mov bx,data_4g
mov ds,bx
mov ebx,esi
mov eax,user_program_position_in_disk
call code_32_core_library:read_hard_disk
push eax
push ebx
mov eax,[esi]
xor edx,edx
mov ecx,512
div ecx
cmp edx,0
jne @1;如果余数为0，那么将商的值减一
dec eax
@1:
mov ecx,eax
cmp ecx,0
pop ebx
pop eax
je @2;若值为0，说明已经不需要加载了
@3:
call code_32_core_library:read_hard_disk
loop @3
@2:
pop eax
mov ds,ax
mov [free_mem_addr],ebx
;2、为用户创建各种段描述符
push ds
mov bx,data_4g
mov ds,bx
mov eax,dword [esi+10]
add eax,esi
mov ebx,0xfffff
mov ecx,code_32_user
shl ecx,16
add ecx,RXS_code
call code_32_core_library:update_gdt

mov eax,dword [esi+14]
add eax,esi
mov ebx,0xfffff
mov ecx,data_32_user
shl ecx,16
add ecx,RWS_data
call code_32_core_library:update_gdt

pop eax
mov ds,ax
mov eax,[free_mem_addr]
add eax,4*1024
mov ebx,0xffffe
mov ecx,stack_32_user
shl ecx,16
add ecx,RWG_stack
call code_32_core_library:update_gdt
mov eax,[free_mem_addr]
add eax,4*1024
mov [free_mem_addr],eax
;4、保存内核堆栈
mov eax,esp
mov [store_esp],eax
;5、设置用户程序的段
mov ax,stack_32_user
mov ss,ax
xor esp,esp
mov ax,data_show
mov gs,ax
mov ax,data_4g
mov es,ax
;5、控制权交给用户程序
push ds
mov bx,data_4g
mov ds,bx
jmp far [esi+4]
pop esi
pop edx
pop ecx
pop ebx
ret