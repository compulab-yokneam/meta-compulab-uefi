FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/:"

build_efi_cfg[noexec] = "1"

SRC_SUB = "grub-conf"
SRC_URI += "file://grub.cfg.main;subdir=${SRC_SUB}"
SRC_URI += "file://grub.cfg.dtb;subdir=${SRC_SUB}"
SRC_URI += "file://grub.cfg.debug;subdir=${SRC_SUB}"
SRC_URI += "file://08_linux_compulab"
SRC_URI += "file://10_linux_compulab"
GRUB_CONF_DEBIAN = "grub-bootconf-debian"
GRUB_CONF = "grub-bootconf"
GRUB_DEFA = "grub-default"

grub_main() {
    local in=${WD}/grub.cfg.main
    local console=$(printf "${SERIAL_CONSOLES}" | awk -F";" '($0=$2","$1"n8")')
    sed "s/\(default_console\)=.*\"$/\1=\"${console}\"/g;s|GRUB_BOOT_DEVICETREE|${GRUB_BOOT_DEVICETREE}|g;s|%%PARTUUID%%|${PARTUUID}|g;s|%%UUID%%|${UUID}|g;s|ROOTMODES|${ROOTMODES}|g;" ${in}
}

grub_dtb() {
    local in=${WD}/grub.cfg.dtb
    sed 's/\(^.*$\)/\t\1/' ${in}
    printf "\n"
}

grub_debug() {
    local in=${WD}/grub.cfg.debug
    sed "s/\(^.*$\)/\t\1/g" ${in}
    printf "\n"
}

grub_cfg_create() {
    grub_main
    printf "\nsubmenu \"Advanced Boot Options\" --id=\"Advanced_boot_options\" {\n\tload_env\n"
    grub_dtb
    grub_debug
    printf "\n}\n"
}

grub_dtb_create() {
    printf "submenu \"Advanced Device Tree Options\" --id=\"Advanced_devive_tree__options\" {\n"
    printf "\tload_env\n"
    printf "\tsearch --no-floppy --fs-uuid --set=root ROOT_UUID\n"
    grub_dtb
    printf "}\n"
}

grub_def_create() {
printf "GRUB_CMDLINE_LINUX_DEFAULT=\"console=tty1 "
for _c in "${SERIAL_CONSOLES}";do
    printf "$_c" | awk -F";" '$0="console="$2","$1"n8 "' ORS=" "
done
printf "compulab=yes\"\n"
printf "GRUB_TERMINAL=console\n"
}

do_install:prepend() {
    export WD="${WORKDIR}/${SRC_SUB}"
    grub_cfg_create > ${GRUB_CONF}
}

do_install:append() {
	install -d ${D}${sysconfdir}/grub.d/
	install -m 0755 ${WORKDIR}/08_linux_compulab ${D}${sysconfdir}/grub.d/
	install -m 0755 ${WORKDIR}/10_linux_compulab ${D}${sysconfdir}/grub.d/

	grub_def_create > ${GRUB_DEFA}
	grub_dtb_create > ${GRUB_CONF_DEBIAN}

	install -d ${D}${datadir}/compulab/
	install -m 0664 ${GRUB_CONF} ${D}${datadir}/compulab/${GRUB_CONF}-yocto
	install -m 0664 ${GRUB_DEFA} ${D}${datadir}/compulab/
	install -m 0664 ${GRUB_CONF_DEBIAN} ${D}${datadir}/compulab/

}

FILES:${PN} += " \
	${datadir}/* \
	${sysconfdir}/* \
"

RDEPENDS:${PN} += " bash "
