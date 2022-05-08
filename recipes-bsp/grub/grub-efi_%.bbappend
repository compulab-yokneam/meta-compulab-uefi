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
