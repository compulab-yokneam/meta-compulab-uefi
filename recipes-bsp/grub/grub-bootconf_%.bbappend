FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/mx8:"

build_efi_cfg[noexec] = "1"

SRC_URI += "file://grub-bootconf.mod"

do_install_prepend() {

bootconf_in="bootconf.in"
rm -rf ${bootconf_in}

dtb_default="${GRUB_BOOT_DEVICETREE}"

echo "
default=${dtb_default}
timeout=10
" >> ${bootconf_in}

echo "
menuentry \"Boot Linux\" --id=\"${dtb_default}\" {
	devicetree (hd0,gpt2)/boot/${dtb_default}
	linux (hd0,gpt2)\${image} root=\${root} \${bootargs}
}" >> ${bootconf_in}

echo "
menuentry \"Install Linux\" --id=\"Install\" {
	devicetree (hd0,gpt2)/boot/${dtb_default}
	linux (hd0,gpt2)\${image} root=\${root} \${bootargs} init=/usr/local/bin/cl-init
}" >> ${bootconf_in}

echo "
submenu \"Advanced Boot Options\" --id=\"Advanced_boot_options\" {
" >> ${bootconf_in}

for dtb_full_path in ${KERNEL_DEVICETREE}; do
dtb_path=$(basename ${dtb_full_path})

echo "
menuentry \"Boot Debug Linux with ${dtb_path}\" --id=\"${dtb_path}_debug\" {
	devicetree (hd0,gpt2)/boot/${dtb_path}
	linux (hd0,gpt2)\${image} root=\${root} \${bootargs} debug initcall_debug
}" >> ${bootconf_in}

done

echo "
}" >> ${bootconf_in}

cat grub-bootconf.mod ${bootconf_in} > grub-bootconf

console=$(echo -n "${SERIAL_CONSOLES}" | awk -F";" '($0=$2","$1"n8")')
sed -i "s/\(console\)=.*\"$/\1=${console}\"/" grub-bootconf.mod

}
