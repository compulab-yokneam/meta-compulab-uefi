# Created by bbappend

root=/dev/mmcblk1p2
image=/boot/Image
set console_bootargs="console=ttymxc2,115200n8"
set rootargs="rootwait"
set bootargs="${bootargs} ${console_bootargs} ${rootargs}"

default=Boot
timeout=10

menuentry "Boot" {
	devicetree (hd0,gpt2)/boot/sbc-mcm-imx8m-mini.dtb
	linux (hd0,gpt2)${image} root=${root} ${bootargs}
}

menuentry "Installer" {
	devicetree (hd0,gpt2)/boot/sbc-mcm-imx8m-mini.dtb
	linux (hd0,gpt2)${image} root=${root} ${bootargs} init=/usr/local/bin/cl-init
}

menuentry "Debug" {
	devicetree (hd0,gpt2)/boot/sbc-mcm-imx8m-mini.dtb
	linux (hd0,gpt2)${image} root=${root} ${bootargs} debug initcall_debug
}

menuentry "Thermal" {
	devicetree (hd0,gpt2)/boot/mx8m-mini-thermal.dtb
	linux (hd0,gpt2)${image} root=${root} ${bootargs}
}
