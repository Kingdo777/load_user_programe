all:
	nasm mbr.asm -o mbr.bin
	nasm core.asm -o core.bin
	nasm user.asm -o user.bin
	dd if=mbr.bin of=disk.img count=1 bs=512
	dd if=core.bin of=disk.img bs=512 seek=1
	dd if=user.bin of=disk.img bs=512 seek=50
	dd if=diskdata.txt of=disk.img bs=512 seek=100
	bochsdbg
