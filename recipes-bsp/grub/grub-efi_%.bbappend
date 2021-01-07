pkg_postinst_ontarget_${PN}-env() {
    CMD=/usr/bin/grub-editenv
    ENV=boot/EFI/BOOT/grubenv
    if [ -z $D ]; then
        D="/"
    fi
    if [ ! -e $D/$ENV ]; then
        $CMD $D/$ENV create
    fi
}

pkg_postinst_${PN}-env () {
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
RDEPENDS_${PN} += "${PN}-env"
RDEPENDS_${PN}-env += "${PN}-editenv"
ALLOW_EMPTY_${PN}-env = "1"

GRUB_BUILDIN_append = " gzio "
