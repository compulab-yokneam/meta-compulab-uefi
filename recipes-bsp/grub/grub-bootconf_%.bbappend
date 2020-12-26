FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/mx8:"

build_efi_cfg[noexec] = "1"

SRC_URI += "file://grub-bootconf.mod"

do_install_prepend() {
	cp grub-bootconf.mod grub-bootconf
}
