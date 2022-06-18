GRUB_IMAGE_DEFAULT = "bootaa64.efi"

GRUB_BUILDIN += "boot linux ext2 fat serial part_msdos part_gpt normal \
                 efi_gop iso9660 configfile search loadenv test reboot progress help lsefi echo loadenv fdt sleep"

do_install:append() {
    rm -rf ${D}${EFI_FILES_PATH}/${GRUB_IMAGE}
    install -m 644 ${B}/${GRUB_IMAGE_PREFIX}${GRUB_IMAGE} ${D}${EFI_FILES_PATH}/${GRUB_IMAGE_DEFAULT}
}

FILES:${PN}:remove = " \
    ${EFI_FILES_PATH}/${GRUB_IMAGE} \
"

FILES:${PN} += " \
    ${EFI_FILES_PATH}/${GRUB_IMAGE_DEFAULT} \
"

pkg_postinst_ontarget:${PN}-env() {
    CMD=/usr/bin/grub-editenv
    ENV=boot/EFI/BOOT/grubenv
    if [ -z $D ]; then
        D="/"
    fi
    if [ ! -e $D/$ENV ]; then
        $CMD $D/$ENV create
    fi
}

pkg_postinst:${PN}-env () {
    CMD=/usr/bin/grub-editenv
    ENV=boot/EFI/BOOT/grubenv
    if [ -z $D ]; then
        D="/"
    fi
    if [ ! -e $D/$ENV ]; then
        $CMD $D/$ENV create
    fi
}

PACKAGES =+ "${PN}-env"
RDEPENDS:${PN} += "${PN}-env"
RDEPENDS:${PN}-env += "${PN}-editenv"
ALLOW_EMPTY:${PN}-env = "1"

GRUB_BUILDIN:append = " gzio "
