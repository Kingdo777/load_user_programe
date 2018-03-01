;类陷入指令
trap:
;输入：esi->要调用的函数的索引号(ESI做参数只能用于trap函数，es的值无法使用，这是这个方法必须的)
mov edi,data_32_core
mov es,edi
;保存传入的参数值
push eax
push ebx
mov eax,esi
mov ebx,6
mul ebx
mov esi,eax
add esi,function_offset_table
pop ebx
pop eax
call far [es:esi]
;恢复用户栈
retf