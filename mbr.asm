;引导扇区代码
%include "stdvar.asm"
org 0x7c00
;设置数据段
mov ax,gdt_start_position
shr ax,4
mov ds,ax
;设置栈段
xor eax,eax
mov ss,ax
mov ax,0x7c00
mov sp,ax

;构建gdt
xor esi,esi
;0号空描述符
xor ebx,ebx
xor cx,cx
call make_gdt
;可访问4G大小内存空间的数据段
mov eax,0x00
mov ebx,0xfffff
mov ecx,RWG_data
call make_gdt
;显存部分对应的段
mov eax,0xB8000
mov ebx,0x7fff
mov ecx,RWS_data
call make_gdt
;进入保护模式后用于执行引导程序的32位代码段
mov eax,0x7c00
mov ebx,0x1ff
mov cx,RXS_code
call make_gdt
;加载gdtr
lgdt [cs:gdt]
;关闭中断
cli
;打开A20
in al,0x92
or al,0x02
out 0x92,al
;打开cr0的保护位
mov eax,cr0
or eax,1
mov cr0,eax
;历史性一跳
jmp dword code_32_mbr:(protectModeStart-0x7c00)
;------函数：写一个段描述符----------
;参数：
;eax->基址
;ebx->界限（高12位无效）
;cx->属性(0-15位对应40-55位，其中对应段界限部分无效)
;ds:esi->描述符的写入起始位置
;返回值：
;esi=esi+8
make_gdt:;16位模式
mov [esi],bx
mov [esi+2],ax
shr eax,16
ror eax,8
bswap eax
and ebx,0x000f0000
add eax,ebx
mov bx,cx
shl ebx,8
and ebx,0x00f0ff00
add eax,ebx
mov [esi+4],eax
add esi,8
dec si
mov [cs:gdt],si
inc si
ret
;----------保护模式代码段---------------------------------
[bits 32]
protectModeStart:
mov ax,data_4g
mov ds,ax
;将内核代码加载到内存
mov eax,core_program_position_in_disk
mov ebx,core_program_load_position
call read_hard_disk_0
push eax
push ebx
mov eax,[core_program_load_position]
xor edx,edx
mov ecx,512
div ecx
cmp edx,0
jne @1;如果余数为0，那么将商的值减一
dec eax
@1:
mov ecx,eax
pop ebx
pop eax
cmp ecx,0
je @2;若值为0，说明已经不需要加载了
@3:
call read_hard_disk_0
loop @3
@2:
;构造内核用到的段
;内核代码段
mov edi,core_program_load_position+10
mov eax,[edi]
add eax,core_program_load_position
mov ebx,0xfffff
mov ecx,RXS_code
call make_gdt_32
;内核数据段
mov eax,[edi+4]
add eax,core_program_load_position
mov ebx,0xfffff
mov ecx,RWS_data
call make_gdt_32
;内核栈段
mov eax,[edi+8]
add eax,core_program_load_position
add eax,dword [edi+4]
mov ebx,0xffffe
mov ecx,RWG_stack
call make_gdt_32
;内核例程代码段
mov eax,[edi+12]
add eax,core_program_load_position
mov ebx,0xfffff
mov ecx,RXS_code
call make_gdt_32

lgdt [gdt]

;跳转到内核代码
jmp far [core_program_load_position+4]
;------函数：从磁盘中加载一个磁盘块到内存------------------------------------------------
read_hard_disk_0:;从硬盘读取一个逻辑扇区
                 ;输入：EAX=起始逻辑扇区号;DS:EBX=目标缓冲区地址
                 ;输出：eax=eax+1;ebx=ebx+512
push ecx
push edx
push eax
;第一步，设置读取扇区的数目
mov dx,0x1f2
mov al,1;读取1个扇区
out dx,al
;第二步，设置扇区的起始地址（由EAX提供）
pop eax
push eax
mov dx,0x1f3
out dx,al

mov dx,0x1f4
shr eax,8
out dx,al

mov dx,0x1f5
shr eax,8
out dx,al

mov dx,0x1f6
shr eax,8
and al,0x0f
add al,0xe0;e（1110）表示主硬盘LBA模式
out dx,al
;第三步，设置读写命令
mov dx,0x1f7
mov al,0x20
out dx,al
;第四步，等待硬盘空闲
mov dx,0x1f7
wait_disk:
in al,dx
and al,0x88
cmp al,0x08
jne wait_disk
;第五步，从数据端口读取数据
mov dx,0x1f0
mov ecx,256;一个扇区512字节，每次读取一个字，一共读取256次,读取的数据通过变址寻址存放到[bx]中
r_eDisk:
in ax,dx
mov [ebx],ax
add ebx,2
loop r_eDisk
pop eax
inc eax
pop edx
pop ecx
ret
;------函数：与make_gdt完全相同，但是一个在16位模式下使用，一个在32位模式下使用----------
make_gdt_32:;32位模式
mov [esi+gdt_start_position],bx
mov [esi+gdt_start_position+2],ax
shr eax,16
ror eax,8
bswap eax
and ebx,0x000f0000
add eax,ebx
mov bx,cx
shl ebx,8
and ebx,0x00f0ff00
add eax,ebx
mov [esi+gdt_start_position+4],eax
add esi,8
dec si
mov [gdt],si
inc si
ret

;用于存放gdtr的信息
gdt:
gdt_size:	dw 0
gdt_addr:	dd 0x7e00

times (510-($-$$)) db 0
dw 0xaa55