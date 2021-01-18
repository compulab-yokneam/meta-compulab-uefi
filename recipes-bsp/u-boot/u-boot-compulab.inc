FILESEXTRAPATHS_prepend := "${THISDIR}/compulab/imx8mm:"

require compulab/imx8mm.inc

PROVIDES += "u-boot"
RPROVIDES_${PN} += "u-boot"

do_configure_efi() {
    sed -i '/# CONFIG_EFI_LOADER is not set/d;$ a CONFIG_EFI_LOADER=y' ${S}/configs/${MACHINE}_defconfig
}

addtask do_configure_efi after do_patch before do_configure
