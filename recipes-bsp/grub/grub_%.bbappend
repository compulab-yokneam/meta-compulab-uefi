do_install_append() {

	ARCH_DIR="arm64-efi"
	GRUB_MOD_DST_PATH="${D}/boot/EFI/BOOT/${ARCH_DIR}"
	GRUB_MOD_SRC_PATH="${D}/usr/lib/grub/${ARCH_DIR}"

	install -d ${GRUB_MOD_DST_PATH}
	for mod in ${GRUB_MOD_SRC_PATH}/*.mod ;do
		install -m 0644 ${mod} ${GRUB_MOD_DST_PATH}/
	done
}

PACKAGES =+ "${PN}-bootmod"
RDEPENDS_${PN} += "${PN}-bootmod"
FILES_${PN}-bootmod = "/boot/EFI/BOOT/arm64-efi"
