;模拟陷入指令进行系统调用
;输入：esi->要调用的函数的索引号
system:
push ds
push es
push gs
push fs
push eax
push ebx
push ecx
push edx
push edi
push esi
call code_32_core_library:0;我默认陷入指令是0号指令
pop esi
pop edi
pop edx
pop ecx
pop ebx
pop eax
pop fs
pop gs
pop es
pop ds
ret