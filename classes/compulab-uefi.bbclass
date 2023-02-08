compulab_fstab_ro() {
    if [ -f ${IMAGE_ROOTFS}/etc/fstab ]; then
        sed -i 's/\(^\/dev\/root\)/#\1/g' ${IMAGE_ROOTFS}/etc/fstab
    fi
}

compulab_grub_extra() {
    if [ -f ${IMAGE_ROOTFS}/boot/EFI/BOOT/grub.cfg ]; then
        eval $(awk -F"=" '(/PRETTY_NAME/)' ${IMAGE_ROOTFS}/usr/lib/os-release)
        sed -i "s|DISTRO|${PRETTY_NAME}|g" ${IMAGE_ROOTFS}/boot/EFI/BOOT/grub.cfg
    fi
}
