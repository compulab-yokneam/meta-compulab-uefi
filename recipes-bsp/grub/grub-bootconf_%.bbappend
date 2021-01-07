FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/:"

build_efi_cfg[noexec] = "1"

SRC_SUB = "grub-conf"
SRC_URI += "file://grub.cfg.main;subdir=${SRC_SUB}"
SRC_URI += "file://grub.cfg.dtb;subdir=${SRC_SUB}"
SRC_URI += "file://grub.cfg.debug;subdir=${SRC_SUB}"
GRUB_CONF = "grub-bootconf"

grub_main() {
    local in=${WD}/grub.cfg.main
    local console=$(printf "${SERIAL_CONSOLES}" | awk -F";" '($0=$2","$1"n8")')
    sed "s/\(default_console\)=.*\"$/\1=\"${console}\"/g;s|GRUB_ROOT_DEVICE|${GRUB_ROOT_DEVICE}|g;s|GRUB_BOOT_DEVICETREE|${GRUB_BOOT_DEVICETREE}|g;s|%%PARTUUID%%|${PARTUUID}|g;s|%%UUID%%|${UUID}|g" ${in}
}

grub_dtb() {
    local in=${WD}/grub.cfg.dtb
    for DTB in ${KERNEL_DEVICETREE};do
        DEVICE_TREE_LIST=${DEVICE_TREE_LIST}" "$(basename ${DTB})
    done
    sed "s/DEVICE_TREE_LIST/${DEVICE_TREE_LIST}/g;s/\(^.*$\)/\t\1/g" ${in}
    printf "\n"
}

grub_debug() {
    local in=${WD}/grub.cfg.debug
    sed "s/\(^.*$\)/\t\1/g" ${in}
}

grub_cfg_create() {
    grub_main
    printf "\nsubmenu \"Advanced Boot Options\" --id=\"Advanced_boot_options\" {\n\n"
    grub_dtb
    grub_debug
    printf "\n}\n"
}

do_install_prepend() {
    export WD="${WORKDIR}/${SRC_SUB}"
    grub_cfg_create > ${GRUB_CONF}
}
