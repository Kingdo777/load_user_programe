;读磁盘
read_hard_disk:	 ;从硬盘读取一个逻辑扇区
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
retf