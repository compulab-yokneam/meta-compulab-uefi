# Created by bbappend

root=/dev/mmcblk1p2
image=/boot/Image
set console_bootargs="console=ttymxc2,115200n8"
set rootargs="rootwait"
set bootargs="${bootargs} ${console_bootargs} ${rootargs}"

default=boot
timeout=10

menuentry "boot" {
	linux (hd0,gpt2)${image} root=${root} ${bootargs}
}

menuentry "debug" {
	linux (hd0,gpt2)${image} root=${root} ${bootargs} debug initcall_debug
}
