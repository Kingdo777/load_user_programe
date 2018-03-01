;更新段描述表
;参数：
;eax->基址
;ebx->界限（高12位无效）
;cx->属性(0-15位对应40-55位，其中对应段界限部分无效)
;ecx高16位->选择子
;返回值：
;更新[ds:gdt]
update_gdt:
push esi
push es
push ds
mov edx,data_4g
mov es,edx
mov edx,data_32_core
mov ds,edx
mov edx,ecx
shr edx,16
and edx,0x0000fff8
mov esi,[gdt_addr]
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
pop eax
mov ds,ax
pop eax
mov es,ax
pop esi
retf