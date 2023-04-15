FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/:"

build_efi_cfg[noexec] = "1"

SRC_URI += "file://grub.cfg.main"
SRC_URI += "file://grub.cfg.dtb"
SRC_URI += "file://grub.cfg.debug"
SRC_URI += "file://08_linux_compulab"
SRC_URI += "file://10_linux_compulab"
SRC_URI += "file://cl-grub-install"
SRC_URI += "file://cl-grub-mkimage"
SRC_URI += "file://grub.in"
SRC_URI += "file://grub.boot.in"

GRUB_CONF_DEBIAN = "grub-bootconf-debian"
GRUB_CONF_BOOT = "grub-bootconf"
GRUB_CONF_ROOT = "grub-bootconf.root"
GRUB_DEFA = "grub-default"

grub_main() {
    local in=${WORKDIR}/grub.cfg.main
    local console="$(printf "${SERIAL_CONSOLES}" | awk -F";" '($0=$2","$1"n8")')"
    sed "s/\(default_console\)=.*\"$/\1=\"${console}\"/g;s|GRUB_BOOT_DEVICETREE|${GRUB_BOOT_DEVICETREE}|g;s|%%PARTUUID%%|${PARTUUID}|g;s|%%UUID%%|${UUID}|g;s|ROOTMODES|${ROOTMODES}|g;" ${in}
}

grub_dtb() {
    local in=${WORKDIR}/grub.cfg.dtb
    sed 's/\(^.*$\)/\t\1/' ${in}
    printf "\n"
}

grub_debug() {
    local in=${WORKDIR}/grub.cfg.debug
    sed "s/\(^.*$\)/\t\1/g" ${in}
    printf "\n"
}

grub_cfg_create_boot() {
    local in=${WORKDIR}/grub.boot.in
    sed "s|%%UUID%%|${UUID}|g" ${in}
}

grub_cfg_create_root() {
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
local _C=""
for serial in $(echo -n "${SERIAL_CONSOLES}" | sed 's/;/-/g'); do
    _C=$_C" "$(printf ${serial} | awk -F"-" '{ print "console="$2","$1"n8" }')
done
sed "s/CONSOLE/${_C}/g" grub.in
}

do_install:prepend() {
    export WORKDIR="${WORKDIR}/${SRC_SUB}"
    grub_cfg_create_boot > ${GRUB_CONF_BOOT}
    grub_cfg_create_root > ${GRUB_CONF_ROOT}
}

do_install:append() {
	install -d ${D}/boot/grub
	install -m 0664 ${GRUB_CONF_ROOT} ${D}/boot/grub/grub.cfg

	install -d ${D}${sysconfdir}/grub.d/
	install -m 0755 ${WORKDIR}/08_linux_compulab ${D}${sysconfdir}/grub.d/
	install -m 0755 ${WORKDIR}/10_linux_compulab ${D}${sysconfdir}/grub.d/

	grub_def_create > ${GRUB_DEFA}
	grub_dtb_create > ${GRUB_CONF_DEBIAN}

	install -d ${D}${datadir}/compulab/
	install -m 0664 ${GRUB_CONF_ROOT} ${D}${datadir}/compulab/${GRUB_CONF_BOOT}-yocto
	install -m 0664 ${GRUB_DEFA} ${D}${datadir}/compulab/
	install -m 0664 ${GRUB_CONF_DEBIAN} ${D}${datadir}/compulab/
	install -d ${D}${prefix}/local/bin
	install -m 0755 ${S}/cl-grub-install ${D}${prefix}/local/bin/
	install -m 0755 ${S}/cl-grub-mkimage ${D}${prefix}/local/bin/
}

PACKAGES:append = " ${PN}-compulab "

FILES:${PN}-compulab += " \
	/boot/grub/* \
	${datadir}/* \
	${sysconfdir}/* \
	${prefix}/local/bin/* \
"

RDEPENDS:${PN}-compulab += " bash "
RDEPENDS:${PN} += " ${PN}-compulab "
