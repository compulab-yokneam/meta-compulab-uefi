GRUB_IMAGE_DEFAULT = "bootaa64.efi"
EFIDIR = "/EFI/BOOT"

GRUB_BUILDIN:append = " all_video boot btrfs cat chain configfile echo efifwsetup efi_gop \
		exfat ext2 fat fdt gcry_sha256 gfxterm gfxterm_background gfxterm_menu \
		gzio halt hashsum help hfsplus iso9660 linux loadenv loopback ls lsefi \
		normal ntfs part_gpt part_msdos progress reboot regexp search \
		search_fs_file search_fs_uuid search_label serial sleep test udf "

do_install:append() {
    rm -rf ${D}${EFI_FILES_PATH}/${GRUB_IMAGE}
    install -m 644 ${B}/${GRUB_IMAGE_PREFIX}${GRUB_IMAGE} ${D}${EFI_FILES_PATH}/${GRUB_IMAGE_DEFAULT}
}

FILES:${PN}:remove = " \
    ${EFI_FILES_PATH}/${GRUB_IMAGE} \
"

FILES:${PN}:append = " \
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
