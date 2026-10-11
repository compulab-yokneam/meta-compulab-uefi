FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://20_linux_xen"

do_install:append () {
    install -d ${D}${sysconfdir}/grub.d
    install -m 0755 ${UNPACKDIR}/20_linux_xen ${D}${sysconfdir}/grub.d/
    sed -i '/efi_uga/d' ${D}${sysconfdir}/grub.d/00_header
}
