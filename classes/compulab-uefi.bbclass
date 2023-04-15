compulab_fstab_ro() {
    if [ -f ${IMAGE_ROOTFS}/etc/fstab ]; then
        sed -i 's/\(^\/dev\/root\)/#\1/g' ${IMAGE_ROOTFS}/etc/fstab
    fi
}

compulab_grub_extra() {
    eval $(awk -F"=" '(/PRETTY_NAME/)' ${IMAGE_ROOTFS}/usr/lib/os-release)
    for grub_cfg in ${IMAGE_ROOTFS}/boot/EFI/BOOT/grub.cfg ${IMAGE_ROOTFS}/boot/grub/grub.cfg;do
        if [ -f ${grub_cfg} ]; then
            sed -i "s|DISTRO|${PRETTY_NAME}|g" ${grub_cfg}
        fi
    done
}
