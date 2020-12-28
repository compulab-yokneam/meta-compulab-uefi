# Created by bbappend

root=/dev/mmcblk1p2
image=/boot/Image
set console_bootargs="console=ttymxc2,115200n8"
set rootargs="rootwait"
set bootargs="${bootargs} ${console_bootargs} ${rootargs}"

default=Boot
timeout=10

