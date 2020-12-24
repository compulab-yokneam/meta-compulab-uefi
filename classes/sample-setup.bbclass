inherit sample-helpers

# ------------------------------ CONFIGURATION ---------------------------------

# The machine to be used for Sample.
# For some reason 'bitbake -e' does not report the MACHINE value so
# we use this as a proxy in case it is not available when needed.
export SAMPLE_MACHINE = "${MACHINE}"
BB_HASHBASE_WHITELIST += "SAMPLE_MACHINE"

# The storage device that holds the device partitions.
SAMPLE_STORAGE_DEVICE ??= "${SAMPLE_STORAGE_DEVICE_DEFAULT}"
SAMPLE_STORAGE_DEVICE_DEFAULT = "/dev/mmcblk0"

# The base name of the devices that hold individual partitions.
# This is often SAMPLE_STORAGE_DEVICE + "p".
SAMPLE_STORAGE_DEVICE_BASE ??= "${SAMPLE_STORAGE_DEVICE_BASE_DEFAULT}"
def sample_linux_partition_base(dev):
    import re
    if re.match("^/dev/[sh]d[a-z]", dev):
        return dev
    else:
        return "%sp" % dev
SAMPLE_STORAGE_DEVICE_BASE_DEFAULT = "${@sample_linux_partition_base('${SAMPLE_STORAGE_DEVICE}')}"

# The partition number holding the boot partition.
SAMPLE_BOOT_PART_NUMBER ??= "${SAMPLE_BOOT_PART_NUMBER_DEFAULT}"
SAMPLE_BOOT_PART_NUMBER_DEFAULT = "1"

# The string path of the boot partition.
SAMPLE_BOOT_PART ??= "${SAMPLE_BOOT_PART_DEFAULT}"
SAMPLE_BOOT_PART_DEFAULT = "${SAMPLE_STORAGE_DEVICE_BASE}${SAMPLE_BOOT_PART_NUMBER}"

# The numbers of the two rootfs partitions in the A/B partition layout.
SAMPLE_ROOTFS_PART_A_NUMBER ??= "${SAMPLE_ROOTFS_PART_A_NUMBER_DEFAULT}"
SAMPLE_ROOTFS_PART_A_NUMBER_DEFAULT = "${@bb.utils.contains('SAMPLE_BOOT_PART_SIZE_MB', '0', '1', '2', d)}"
SAMPLE_ROOTFS_PART_B_NUMBER ??= "${SAMPLE_ROOTFS_PART_B_NUMBER_DEFAULT}"
SAMPLE_ROOTFS_PART_B_NUMBER_DEFAULT = "${@bb.utils.contains('SAMPLE_BOOT_PART_SIZE_MB', '0', '2', '3', d)}"

# The string path of the two rootfs partitions in the A/B partition layout
SAMPLE_ROOTFS_PART_A ??= "${SAMPLE_ROOTFS_PART_A_DEFAULT}"
SAMPLE_ROOTFS_PART_A_DEFAULT = "${SAMPLE_STORAGE_DEVICE_BASE}${SAMPLE_ROOTFS_PART_A_NUMBER}"
SAMPLE_ROOTFS_PART_B ??= "${SAMPLE_ROOTFS_PART_B_DEFAULT}"
SAMPLE_ROOTFS_PART_B_DEFAULT = "${SAMPLE_STORAGE_DEVICE_BASE}${SAMPLE_ROOTFS_PART_B_NUMBER}"

# The names of the two rootfs partitions in the A/B partition layout. By default
# it is the same name as SAMPLE_ROOTFS_PART_A and SAMPLE_ROOTFS_B
SAMPLE_ROOTFS_PART_A_NAME ??= "${SAMPLE_ROOTFS_PART_A_NAME_DEFAULT}"
SAMPLE_ROOTFS_PART_A_NAME_DEFAULT = "${SAMPLE_ROOTFS_PART_A}"
SAMPLE_ROOTFS_PART_B_NAME ??= "${SAMPLE_ROOTFS_PART_B_NAME_DEFAULT}"
SAMPLE_ROOTFS_PART_B_NAME_DEFAULT = "${SAMPLE_ROOTFS_PART_B}"

# The partition number holding the data partition.
SAMPLE_DATA_PART_NUMBER ??= "${SAMPLE_DATA_PART_NUMBER_DEFAULT}"
SAMPLE_DATA_PART_NUMBER_DEFAULT = "${@sample_get_data_part_num(d)}"

# The string path of the the data partition.
SAMPLE_DATA_PART ??= "${SAMPLE_DATA_PART_DEFAULT}"
SAMPLE_DATA_PART_DEFAULT = "${SAMPLE_STORAGE_DEVICE_BASE}${SAMPLE_DATA_PART_NUMBER}"

# The name of of the MTD part holding your UBI volumes.
SAMPLE_MTD_UBI_DEVICE_NAME ??= "${SAMPLE_MTD_UBI_DEVICE_NAME_DEFAULT}"
SAMPLE_MTD_UBI_DEVICE_NAME_DEFAULT = ""

# Filesystem type of data partition. Used for both FS generation and fstab construction
# Leave as default (auto) to generate a partition using the same Filesystem as 
# the rootfs ($ARTIFACTIMG_FSTYPE) and set the fstab to auto-detect the partition type
# Set to a known filesystem to generate the partition using that type
SAMPLE_DATA_PART_FSTYPE ??= "${SAMPLE_DATA_PART_FSTYPE_DEFAULT}"
SAMPLE_DATA_PART_FSTYPE_DEFAULT = "auto"

# Filesystem type of data partition to generate. Used only for FS generation
# Typically you'll be best off setting SAMPLE_DATA_PART_FSTYPE instead
SAMPLE_DATA_PART_FSTYPE_TO_GEN ??= "${SAMPLE_DATA_PART_FSTYPE_TO_GEN_DEFAULT}"
SAMPLE_DATA_PART_FSTYPE_TO_GEN_DEFAULT = "${@bb.utils.contains('SAMPLE_DATA_PART_FSTYPE', 'auto', '${ARTIFACTIMG_FSTYPE}', '${SAMPLE_DATA_PART_FSTYPE}', d)}"

# Set the fstab options for mounting the data partition
SAMPLE_DATA_PART_FSTAB_OPTS ??= "${SAMPLE_DATA_PART_FSTAB_OPTS_DEFAULT}"
SAMPLE_DATA_PART_FSTAB_OPTS_DEFAULT = "defaults"

# Set any extra options for creating the data partition
SAMPLE_DATA_PART_FSOPTS ??= "${SAMPLE_DATA_PART_FSOPTS_DEFAULT}"
SAMPLE_DATA_PART_FSOPTS_DEFAULT = ""

# Filesystem type of boot partition, used for fstab construction.
# Typically the default (auto) will work fine
SAMPLE_BOOT_PART_FSTYPE ??= "${SAMPLE_BOOT_PART_FSTYPE_DEFAULT}"
SAMPLE_BOOT_PART_FSTYPE_DEFAULT = "auto"

# Set the fstab options for mounting the boot partition
SAMPLE_BOOT_PART_FSTAB_OPTS ??= "${SAMPLE_BOOT_PART_FSTAB_OPTS_DEFAULT}"
SAMPLE_BOOT_PART_FSTAB_OPTS_DEFAULT = "defaults,sync"

# Device type of device when making an initial partitioned image.
SAMPLE_DEVICE_TYPE ??= "${SAMPLE_DEVICE_TYPE_DEFAULT}"
SAMPLE_DEVICE_TYPE_DEFAULT = "${MACHINE}"

# To tell the difference from a beaglebone-yocto image with only U-Boot.
SAMPLE_DEVICE_TYPE_DEFAULT_beaglebone-yocto_sample-grub = "${MACHINE}-grub"

# Space separated list of device types compatible with the built update.
SAMPLE_DEVICE_TYPES_COMPATIBLE ??= "${SAMPLE_DEVICE_TYPES_COMPATIBLE_DEFAULT}"
SAMPLE_DEVICE_TYPES_COMPATIBLE_DEFAULT = "${SAMPLE_DEVICE_TYPE}"

# Total size of the medium that sample sdimg will be written to. The size of
# rootfs partition will be calculated automatically by subtracting the size of
# boot and data partitions along with some predefined overhead (see
# SAMPLE_PARTITIONING_OVERHEAD_KB).
SAMPLE_STORAGE_TOTAL_SIZE_MB ??= "${SAMPLE_STORAGE_TOTAL_SIZE_MB_DEFAULT}"
SAMPLE_STORAGE_TOTAL_SIZE_MB_DEFAULT ?= "1024"

# Size of the data partition, which is preserved across updates.
SAMPLE_DATA_PART_SIZE_MB ??= "${SAMPLE_DATA_PART_SIZE_MB_DEFAULT}"
SAMPLE_DATA_PART_SIZE_MB_DEFAULT = "128"

# Size of the swap partition, zero means not required
SAMPLE_SWAP_PART_SIZE_MB ??= "${SAMPLE_SWAP_PART_SIZE_MB_DEFAULT}"
SAMPLE_SWAP_PART_SIZE_MB_DEFAULT = "0"

# Size of the first (FAT) partition, that contains the bootloader
SAMPLE_BOOT_PART_SIZE_MB ??= "${SAMPLE_BOOT_PART_SIZE_MB_DEFAULT}"
SAMPLE_BOOT_PART_SIZE_MB_DEFAULT = "16"

# For performance reasons, we try to align the partitions to the SD card's erase
# block (PEB). It is impossible to know this information with certainty, but one
# way to find out is to run the "flashbench" tool on your SD card and study the
# results. If you do, feel free to override this default.
#
# 8MB alignment is a safe setting that might waste some space if the erase block
# is smaller.
#
# For traditional block storage (HDDs, SDDs, etc), in most cases this is 512
# bytes, often called a sector.
SAMPLE_STORAGE_PEB_SIZE ??= "8388608"

# Historically SAMPLE_PARTITION_ALIGNMENT was always in KiB, but due to UBI
# using some bytes for bookkeeping, each block is not always a KiB
# multiple. Hence it needs to be expressed in bytes in those cases.
SAMPLE_PARTITION_ALIGNMENT ??= "${SAMPLE_PARTITION_ALIGNMENT_DEFAULT}"
# For non-UBI, the alignment should simply be the physical erase block size,
# but it should not be less than 1KiB (wic won't like that).
SAMPLE_PARTITION_ALIGNMENT_DEFAULT = "${@max(${SAMPLE_STORAGE_PEB_SIZE}, 1024)}"

# The reserved space between the partition table and the first partition.
# Most people don't need to set this, and it will be automatically overridden
# by sample-uboot distro feature.
SAMPLE_RESERVED_SPACE_BOOTLOADER_DATA ??= "${SAMPLE_RESERVED_SPACE_BOOTLOADER_DATA_DEFAULT}"
SAMPLE_RESERVED_SPACE_BOOTLOADER_DATA_DEFAULT = "0"

# The interface to load partitions from. This is normally empty, in which case
# it is deduced from SAMPLE_STORAGE_DEVICE. Only use this if the interface
# cannot be deduced from SAMPLE_STORAGE_DEVICE.
SAMPLE_UBOOT_STORAGE_INTERFACE ??= "${SAMPLE_UBOOT_STORAGE_INTERFACE_DEFAULT}"
SAMPLE_UBOOT_STORAGE_INTERFACE_DEFAULT = ""

# The device number of the interface to load partitions from. This is normally
# empty, in which case it is deduced from SAMPLE_STORAGE_DEVICE. Only use this
# if the indexing of devices is different in U-Boot and in the Linux kernel.
SAMPLE_UBOOT_STORAGE_DEVICE ??= "${SAMPLE_UBOOT_STORAGE_DEVICE_DEFAULT}"
SAMPLE_UBOOT_STORAGE_DEVICE_DEFAULT = ""

# This will be embedded into the boot sector, or close to the boot sector, where
# exactly depends on the offset variable. Since it is a machine specific
# setting, the default value is an empty string.
SAMPLE_IMAGE_BOOTLOADER_FILE ??= "${SAMPLE_IMAGE_BOOTLOADER_FILE_DEFAULT}"
SAMPLE_IMAGE_BOOTLOADER_FILE_DEFAULT = ""

# Offset of bootloader, in sectors (512 bytes).
SAMPLE_IMAGE_BOOTLOADER_BOOTSECTOR_OFFSET ??= "${SAMPLE_IMAGE_BOOTLOADER_BOOTSECTOR_OFFSET_DEFAULT}"
SAMPLE_IMAGE_BOOTLOADER_BOOTSECTOR_OFFSET_DEFAULT = "2"

# File to flash into MBR (Master Boot Record) on partitioned images
SAMPLE_MBR_BOOTLOADER_FILE ??= "${SAMPLE_MBR_BOOTLOADER_FILE_DEFAULT}"
SAMPLE_MBR_BOOTLOADER_FILE_DEFAULT = ""
# How many bytes of the MBR to flash.
# 446 avoids the partition table structure. See this link:
# https://pete.akeo.ie/2014/05/compiling-and-installing-grub2-for.html
SAMPLE_MBR_BOOTLOADER_LENGTH ??= "446"

# Board specific U-Boot commands to be run prior to sample_setup
SAMPLE_UBOOT_PRE_SETUP_COMMANDS ??= "${SAMPLE_UBOOT_PRE_SETUP_COMMANDS_DEFAULT}"
SAMPLE_UBOOT_PRE_SETUP_COMMANDS_DEFAULT = ""

# Board specific U-Boot commands to be run after sample_setup
SAMPLE_UBOOT_POST_SETUP_COMMANDS ??= "${SAMPLE_UBOOT_POST_SETUP_COMMANDS_DEFAULT}"
SAMPLE_UBOOT_POST_SETUP_COMMANDS_DEFAULT = ""

# All the allowed sample configuration variables
SAMPLE_CONFIGURATION_VARS ?= "\
    RootfsPartA \
    RootfsPartB \
    InventoryPollIntervalSeconds \
    RetryPollIntervalSeconds \
    ArtifactVerifyKey \
    ServerCertificate \
    ServerURL \
    UpdatePollIntervalSeconds"

# The configuration variables to migrate to the persistent configuration.
SAMPLE_PERSISTENT_CONFIGURATION_VARS ?= "RootfsPartA RootfsPartB"


# --------------------------- END OF CONFIGURATION -----------------------------

IMAGE_INSTALL_append = " sample-client"
IMAGE_CLASSES += "sample-part-images sample-ubimg sample-artifactimg sample-dataimg sample-bootimg sample-datatar"

# Originally defined in bitbake.conf. We define them here so that images with
# the same MACHINE name, but different SAMPLE_DEVICE_TYPE, will not result in
# the same image file name.
IMAGE_NAME = "${IMAGE_BASENAME}-${SAMPLE_DEVICE_TYPE}${IMAGE_VERSION_SUFFIX}"
IMAGE_LINK_NAME = "${IMAGE_BASENAME}-${SAMPLE_DEVICE_TYPE}"

# SAMPLE_FEATURES_ENABLE and SAMPLE_FEATURES_DISABLE map to
# DISTRO_FEATURES_BACKFILL and DISTRO_FEATURES_BACKFILL_CONSIDERED,
# respectively.
DISTRO_FEATURES_BACKFILL_append = " ${SAMPLE_FEATURES_ENABLE}"
DISTRO_FEATURES_BACKFILL_CONSIDERED_append = " ${SAMPLE_FEATURES_DISABLE}"

python() {
    # Add all possible Sample features here. This list is here to have an
    # authoritative list of all distro features that Sample provides.
    # Each one will also define the same string in OVERRIDES.
    sample_features = {

        # For GRUB, use BIOS for booting, instead of the default, UEFI.
        'sample-bios',

        # Integration with GRUB.
        'sample-grub',

        # Install of Sample, with the minimum components. This includes no
        # references to specific partition layouts.
        'sample-client-install',

        # Include components for Sample-partitioned images. This will create
        # files that rely on the Sample partition layout.
        'sample-image',

        # Include components for generating a BIOS GPT image.
        'sample-image-gpt',

        # Include components for generating a BIOS image.
        'sample-image-bios',

        # Include components for generating an SD image.
        'sample-image-sd',

        # Include components for generating a UBI image.
        'sample-image-ubi',

        # Include components for generating a UEFI image.
        'sample-image-uefi',

        # Include Sample as a systemd service.
        'sample-systemd',

        # Enable Sample configuration specific to UBI.
        'sample-ubi',

        # Use Sample together with U-Boot.
        'sample-uboot',

        # Use PARTUUID to set fixed drive locations.
        'sample-partuuid',

        # Setup the systemd machine ID to be persistent across OTA updates.
        'sample-persist-systemd-machine-id',

        # Enable dynamic resizing of the data filesystem through systemd's growfs
        'sample-growfs-data',
    }

    mfe = d.getVar('SAMPLE_FEATURES_ENABLE')
    mfe = mfe.split() if mfe is not None else []
    mfd = d.getVar('SAMPLE_FEATURES_DISABLE')
    mfd = mfd.split() if mfd is not None else []
    for feature in mfe + mfd:
        if not feature.startswith('sample-'):
            bb.fatal("%s in SAMPLE_FEATURES_ENABLE or SAMPLE_FEATURES_DISABLE is not a Sample feature."
                     % feature)

    for feature in d.getVar('DISTRO_FEATURES').split():
        if feature.startswith("sample-"):
            if feature not in sample_features:
                bb.fatal("%s from SAMPLE_FEATURES_ENABLE or DISTRO_FEATURES is not a valid Sample feature."
                         % feature)
            d.setVar('OVERRIDES_append', ':%s' % feature)

            # Verify that all 'sample-' features are added using SAMPLE_FEATURES
            # variables. This is important because we base some decisions on
            # these variables, and then fill DISTRO_FEATURES, which would give
            # infinite recursion if we based the decision directly on
            # DISTRO_FEATURES.
            if feature not in mfe or feature in mfd:
                bb.fatal(("%s is not added using SAMPLE_FEATURES_ENABLE and "
                          + "SAMPLE_FEATURES_DISABLE variables. Please make "
                          + "sure that the feature is enabled using "
                          + "SAMPLE_FEATURES_ENABLE, and is not in "
                          + "SAMPLE_FEATURES_DISABLE.")
                         % feature)
}

def sample_feature_is_enabled(feature, if_true, if_false, d):
    in_enable = bb.utils.contains('SAMPLE_FEATURES_ENABLE', feature, True, False, d)
    in_disable = bb.utils.contains('SAMPLE_FEATURES_DISABLE', feature, True, False, d)

    if in_enable and not in_disable:
        return if_true
    else:
        return if_false

python() {
    if d.getVar('SAMPLE_PARTITION_ALIGNMENT_MB', True):
        bb.fatal("SAMPLE_PARTITION_ALIGNMENT_MB is deprecated. Please define SAMPLE_PARTITION_ALIGNMENT instead.")
    if d.getVar('SAMPLE_PARTITION_ALIGNMENT_KB', True):
        bb.fatal("SAMPLE_PARTITION_ALIGNMENT_KB is deprecated. Please define SAMPLE_PARTITION_ALIGNMENT instead.")
    if d.getVar('SAMPLE_STORAGE_RESERVED_RAW_SPACE', True):
        bb.fatal("SAMPLE_STORAGE_RESERVED_RAW_SPACE is deprecated. Please define SAMPLE_RESERVED_SPACE_BOOTLOADER_DATA instead.")
    if d.getVar('IMAGE_BOOTLOADER_FILE', True):
        bb.fatal("IMAGE_BOOTLOADER_FILE is deprecated. Please define SAMPLE_IMAGE_BOOTLOADER_FILE instead.")
    if d.getVar('IMAGE_BOOTLOADER_BOOTSECTOR_OFFSET', True):
        bb.fatal("IMAGE_BOOTLOADER_BOOTSECTOR_OFFSET is deprecated. Please define SAMPLE_IMAGE_BOOTLOADER_BOOTSECTOR_OFFSET instead.")
    if d.getVar('SAMPLE_DATA_PART_DIR'):
        bb.fatal("SAMPLE_DATA_PART_DIR is deprecated. Please use recipes to add files directly to /data instead.")
}

addhandler sample_sanity_handler
sample_sanity_handler[eventmask] = "bb.event.ParseCompleted"
python sample_sanity_handler() {
    if bb.utils.contains('SAMPLE_FEATURES_ENABLE', 'sample-partuuid', True, False, d) and d.getVar('SAMPLE_STORAGE_DEVICE', True) != "":
        bb.warn("SAMPLE_STORAGE_DEVICE is ignored when sample-partuuid is enabled. Clear SAMPLE_STORAGE_DEVICE to remove this warning.")

    if bb.utils.contains('SAMPLE_FEATURES_ENABLE', 'sample-partuuid', True, False, d) and bb.utils.contains('SAMPLE_FEATURES_ENABLE', 'sample-uboot', True, False, d):
        bb.fatal("sample-partuuid is not supported with sample-uboot.")
}


def sample_get_bytes_with_unit(bytes):
    if bytes % 1048576 == 0:
        return "%dm" % (bytes / 1048576)
    if bytes % 1024 == 0:
        return "%dk" % (bytes / 1024)
    return "%d" % bytes


addhandler sample_vars_handler
sample_vars_handler[eventmask] = "bb.event.ParseCompleted"
python sample_vars_handler() {
    from bb import data
    import os
    import re
    import json

    path = d.getVar("LAYERDIR_SAMPLE")
    path = os.path.join(path, "conf/sample-vars.json")

    if os.path.isfile(path):
        sample_vars = {}
        with open(path, "r") as f:
            sample_vars = json.load(f)

        for k in d.keys():
            if k.startswith("SAMPLE_"):
                if re.search("_[-a-z0-9][-\w]*$", k) != None:
                    # skip variable overrides
                    continue;

                if k not in sample_vars.keys():
                    # Warn if user has defined some new (unused) SAMPLE_.* variables
                    bb.warn("\"%s\" is not a recognized SAMPLE_ variable. Typo?" % k)

                elif sample_vars[k] != "":
                    # If certain keys should have associated some restricted value
                    # (expressed in regular expression in the .json-file)
                    # NOTE: empty strings (json-values) are only compared by key, 
                    #       whereas the value is arbitrary
                    expected_expressions = []
                    val = d.getVar(k)

                    if isinstance (sample_vars[k], list):
                        # item is a list of strings
                        for regex in sample_vars[k]: # (can be a list of items)
                            if re.search(regex, val) == None:
                                expected_expressions += [regex]
                        if len(expected_expressions) > 0: 
                            bb.note("Variable \"%s\" does not contain suggested value(s): {%s}" %\
                                    (k, ', '.join(expected_expressions)))

                    else: 
                        # item is a single string
                        regex = sample_vars[k]
                        if re.search(regex, val) == None: 
                            bb.note("%s initialized with value \"%s\"" % (k, val),\
                                    " | Expected[regex]: \"%s\"" % regex)

    else: ## if !os.path.isfile(path): ##
        # This should never run, but left it in here in case we #
        # need to generate new json file template in the future #
        sample_vars = {}
        for k in d.keys():
            if k.startswith("SAMPLE_"):
                if re.search("_[-a-z0-9][-\w]*$", k) == None:
                    sample_vars[k] = ""
                    #sample_vars[k] = d.getVar(k) might be useful for inspection
        with open (path, 'w') as f:
            json.dump(sample_vars, f, sort_keys=True, indent=4)
}

# Including these does not mean that all these features will be enabled, just
# that their configuration will be considered. Use DISTRO_FEATURES to enable and
# disable features.
include sample-setup-bios.inc
include sample-setup-grub.inc
include sample-setup-image.inc
include sample-setup-install.inc
include sample-setup-systemd.inc
include sample-setup-ubi.inc
include sample-setup-uboot.inc
