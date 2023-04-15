FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://10_linux"

do_install:append () {
    install -d ${D}${sysconfdir}/grub.d
    install -m 0755 ${WORKDIR}/10_linux ${D}${sysconfdir}/grub.d/
}
