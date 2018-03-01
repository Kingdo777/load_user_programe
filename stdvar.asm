;我是全局头文件，里面都是一些常量或者宏的定义等等
user_program_load_position equ 0x100000
core_program_load_position equ 0x17e00
gdt_start_position equ 0x7e00

core_program_position_in_disk 	equ 1
user_program_position_in_disk	equ 50
test_file_position_in_disk		equ 100

;段描述符相关
;				G_D/B_L_AVL_offset_P_DPL_S_TYPE
RWG_data 	equ 1__1__0__0___0000__1_00__1_0010B 	;32位可读可写大粒度数据段
RWS_data 	equ 0__1__0__0___0000__1_00__1_0010B	;32位可读可写小粒度数据段
RWG_stack 	equ 1__1__0__0___0000__1_00__1_0110B	;32位可读可写大粒度栈段
RXS_code	equ 0__1__0__0___0000__1_00__1_1010B	;32位可读可执行小粒度非一致代码段

;选择子
data_4g					equ 1*8;4G空间内存数据段
data_show				equ 2*8;显存数据段
code_32_mbr				equ 3*8;引导程序保护模式代码段
code_32_core			equ 4*8;内核的代码段 
data_32_core			equ 5*8;内核的数据段
stack_32_core			equ 6*8;内核的栈段
code_32_core_library 	equ 7*8;内核的例程代码段
code_32_user			equ 8*8;用户的代码段 
data_32_user			equ 9*8;用户的数据段
stack_32_user			equ 10*8;用户的栈段

;显示样式
;--背景--				K R G B I R G B
flickering 			equ 1_0_0_0_0_0_0_0B;背景闪烁
back_black			equ 0_0_0_0_0_0_0_0B;黑色背景
back_blue			equ 0_0_0_1_0_0_0_0B;蓝色背景
back_green			equ 0_0_1_0_0_0_0_0B;绿色背景
back_cyan			equ 0_0_1_1_0_0_0_0B;青色背景
back_red			equ 0_1_0_0_0_0_0_0B;红色背景
back_magenta		equ 0_1_0_1_0_0_0_0B;品红色背景
back_brown			equ 0_1_1_0_0_0_0_0B;棕色背景
back_white			equ 0_1_1_1_0_0_0_0B;白色背景
;前景
lighting			equ 0_0_0_0_1_0_0_0B;前景加亮
front_black			equ 0_0_0_0_0_0_0_0B;黑色前景
front_blue			equ 0_0_0_0_0_0_0_1B;蓝色前景
front_green			equ 0_0_0_0_0_0_1_0B;绿色前景
front_cyan			equ 0_0_0_0_0_0_1_1B;青色前景
front_red			equ 0_0_0_0_0_1_0_0B;红色前景
front_magenta		equ 0_0_0_0_0_1_0_1B;品红色前景
front_brown			equ 0_0_0_0_0_1_1_0B;棕色前景
front_white			equ 0_0_0_0_0_1_1_1B;白色前景

;例程代码函数索引
trap_index				equ 0x00
put_string_index		equ 0x01
read_disk_index			equ 0x02
make_gdt_index			equ 0x03
update_gdt_index		equ 0x04