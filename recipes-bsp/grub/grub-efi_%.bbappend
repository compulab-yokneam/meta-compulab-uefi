pkg_postinst_${PN}-env () {
    ENV=boot/EFI/BOOT/grubenv
    if [ -z $D ]; then
        D="/"
    fi
    if [ ! -e $D/$ENV ]; then
        grub-editenv $D/$ENV create
    fi
}

PACKAGES =+ "${PN}-env"
RDEPENDS_${PN} += "${PN}-env"
ALLOW_EMPTY_${PN}-env = "1"

GRUB_BUILDIN_append = " gzio "
