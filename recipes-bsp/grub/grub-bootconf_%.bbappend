FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/mx8:"

build_efi_cfg[noexec] = "1"

SRC_URI += "file://grub-bootconf.mod"

do_install_prepend() {
bootconf_in="bootconf.in"
rm -rf ${bootconf_in}

for dtb_full_path in ${KERNEL_DEVICETREE}; do
dtb_path=$(basename ${dtb_full_path})
dtb_install=${dtb_install:-${dtb_path}}

echo "
menuentry \"Boot Linux with ${dtb_path}\" {
	devicetree (hd0,gpt2)/boot/${dtb_path}
	linux (hd0,gpt2)/\${image} root=\${root} \${bootargs}
}" >> ${bootconf_in}

done

echo "
menuentry \"Install Linux\" {
	devicetree (hd0,gpt2)/boot/${dtb_install}
	linux (hd0,gpt2)/\${image} root=\${root} \${bootargs} init=/usr/local/bin/cl-init
}" >> ${bootconf_in}

cat ${bootconf_in} >> grub-bootconf.mod
cp grub-bootconf.mod grub-bootconf

CONSOLE=$(echo -n ${SERIAL_CONSOLES} | awk -F";" '($0=$2)')","$(echo -n ${SERIAL_CONSOLES} | awk -F";" '($0=$1)')"n8"
sed -i "s/\(console\)=.*\"$/\1=${CONSOLE}\"/" grub-bootconf.mod

}
