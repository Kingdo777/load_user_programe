;------函数：写一个段描述符----------
;参数：
;eax->基址
;ebx->界限（高12位无效）
;cx->属性(0-15位对应40-55位，其中对应段界限部分无效)
;[ds:gdt]->gdt索引位置，6字节大小
;返回值：
;更新[ds:gdt]
make_gdt:
push edx
push esi
push es
push ds
mov edx,data_4g
mov es,edx
mov edx,data_32_core
mov ds,edx
mov esi,[gdt_addr]
mov dx,[gdt_size]
inc dx
and edx,0x0000ffff
add esi,edx
mov [es:esi],bx
mov [es:esi+2],ax
shr eax,16
ror eax,8
bswap eax
and ebx,0x000f0000
add eax,ebx
mov bx,cx
shl ebx,8
and ebx,0x00f0ff00
add eax,ebx
mov [es:esi+4],eax
add esi,7
mov edx,[gdt_addr]
sub esi,edx
mov [gdt_size],si;gdt_size是16位的哦
pop eax
mov ds,ax
pop eax
mov es,ax
pop esi
pop edx
retf