LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

DEPENDS += "grub grub-efi"
# No information for SRC_URI yet (only an external source tree was specified)
# SRC_URI = ""

do_fetch[noexec] = "1"
do_unpack[noexec] = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install () {
	ARCH_DIR="arm64-efi"
	GRUB_MOD_DST_PATH="${D}/boot/grub/${ARCH_DIR}"
	GRUB_MOD_SRC_PATH="${S}/../recipe-sysroot/usr/lib/grub/${ARCH_DIR}"

	if [ -d ${GRUB_MOD_SRC_PATH} ];then
		install -d ${GRUB_MOD_DST_PATH}
		for mod in ${GRUB_MOD_SRC_PATH}/*.mod ;do
			install -m 0644 ${mod} ${GRUB_MOD_DST_PATH}/
		done
	fi
}

FILES:${PN} = "/boot/grub/arm64-efi"
