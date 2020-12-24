# Class for those who want to enable all Sample required features.

SAMPLE_FEATURES_ENABLE_append = " \
    ${_SAMPLE_BOOTLOADER_DEFAULT} \
    sample-image \
    ${_SAMPLE_IMAGE_TYPE_DEFAULT} \
    sample-client-install \
    sample-systemd \
    ${_SAMPLE_GROWFS_DATA_DEFAULT} \
"

_SAMPLE_IMAGE_TYPE_DEFAULT ?= "sample-image-uefi"
_SAMPLE_BOOTLOADER_DEFAULT ?= "sample-grub"

_SAMPLE_GROWFS_DATA_DEFAULT ?= "${@'' if d.getVar('SAMPLE_EXTRA_PARTS') else 'sample-growfs-data'}"

# Beaglebone reads the first VFAT partition and only understands MBR partition
# table. Even though this is a slight violation of the UEFI spec, change to that
# for Beaglebone.
_SAMPLE_IMAGE_TYPE_DEFAULT_beaglebone-yocto = "sample-image-sd"
