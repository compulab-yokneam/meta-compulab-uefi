################################################################################
# Variables
################################################################################

ARTIFACTIMG_FSTYPE_DEFAULT_sample-ubi = "ubifs"

SAMPLE_STORAGE_DEVICE_DEFAULT_sample-ubi = "ubi0"

# The base name of the devices that hold individual volumes.
SAMPLE_STORAGE_DEVICE_BASE_DEFAULT_sample-ubi = "${SAMPLE_STORAGE_DEVICE}_"

# The numbers of the two rootfs partitions in the A/B partition layout.
SAMPLE_ROOTFS_PART_A_NUMBER_DEFAULT_sample-ubi = "0"
SAMPLE_ROOTFS_PART_B_NUMBER_DEFAULT_sample-ubi = "1"

# The partition number holding the data partition.
SAMPLE_DATA_PART_DEFAULT_sample-ubi = "${SAMPLE_STORAGE_DEVICE_BASE}2"
SAMPLE_DATA_PART_FSTYPE_DEFAULT_sample-ubi = "ubifs"

# u-boot command ubifsmount requires volume name as the only argument
# and hence we need to keep track of that since we load kernel/dtb from
# rootfs part
#
# It also needs the volume index e.g.
# ubifsmount ubi0:rootfsa
SAMPLE_ROOTFS_PART_A_NAME_DEFAULT_sample-ubi = "${SAMPLE_STORAGE_DEVICE}:rootfsa"
SAMPLE_ROOTFS_PART_B_NAME_DEFAULT_sample-ubi = "${SAMPLE_STORAGE_DEVICE}:rootfsb"

# The name of of the MTD part holding your UBI volumes.
SAMPLE_MTD_UBI_DEVICE_NAME_DEFAULT_sample-ubi = "ubi"

# Boot part is not used when building UBI image.
SAMPLE_BOOT_PART_DEFAULT_sample-ubi = ""
SAMPLE_BOOT_PART_NUMBER_DEFAULT_sample-ubi = ""
SAMPLE_BOOT_PART_SIZE_MB_DEFAULT_sample-ubi = "0"

# These are not applicable when building UBI image.
SAMPLE_UBOOT_STORAGE_DEVICE_DEFAULT_sample-ubi = "dummy"
SAMPLE_UBOOT_STORAGE_INTERFACE_DEFAULT_sample-ubi = "dummy"

# Align UBI partitions to the LEB block size instead of the PEB size, since
# the bookeeping bytes used by UBI are basically lost as far as storage space
# is concerned.
SAMPLE_PARTITION_ALIGNMENT_DEFAULT_sample-ubi = "${SAMPLE_UBI_LEB_SIZE}"

# Will be relative to start of first MTD partition, so should be zero.
SAMPLE_IMAGE_BOOTLOADER_BOOTSECTOR_OFFSET_DEFAULT_sample-ubi = "0"

# since UBIFS employs compression, disable the max rootfs size checking.
SAMPLE_IMAGE_ROOTFS_MAXSIZE_DEFAULT_sample-ubi = ""

SAMPLE_PARTITIONING_OVERHEAD_KB_DEFAULT_sample-ubi = "${@sample_get_partitioning_overhead_kb_ubi(d)}"

# Definition of mtdids and mtdparts (taken from U-Boot's mtdparts.c):
#
# 'mtdids' - linux kernel mtd device id <-> u-boot device id mapping
#
# mtdids=<idmap>[,<idmap>,...]
#
# <idmap>    := <dev-id>=<mtd-id>
# <dev-id>   := 'nand'|'nor'|'onenand'<dev-num>
# <dev-num>  := mtd device number, 0...
# <mtd-id>   := unique device tag used by linux kernel to find mtd device (mtd->name)
#
#
# 'mtdparts' - partition list
#
# mtdparts=mtdparts=<mtd-def>[;<mtd-def>...]
#
# <mtd-def>  := <mtd-id>:<part-def>[,<part-def>...]
# <mtd-id>   := unique device tag used by linux kernel to find mtd device (mtd->name)
# <part-def> := <size>[@<offset>][<name>][<ro-flag>]
# <size>     := standard linux memsize OR '-' to denote all remaining space
# <offset>   := partition start offset within the device
# <name>     := '(' NAME ')'
# <ro-flag>  := when set to 'ro' makes partition read-only (not used, passed to kernel)
#
# Notes:
# - each <mtd-id> used in mtdparts must albo exist in 'mtddis' mapping
# - if the above variables are not set defaults for a given target are used
#
# Examples:
#
# 1 NOR Flash, with 1 single writable partition:
# mtdids=nor0=edb7312-nor
# mtdparts=mtdparts=edb7312-nor:-
#
# 1 NOR Flash with 2 partitions, 1 NAND with one
# mtdids=nor0=edb7312-nor,nand0=edb7312-nand
# mtdparts=mtdparts=edb7312-nor:256k(ARMboot)ro,-(root);edb7312-nand:-(home)

# The mtdids present on the device.
# Highly board specific, therefore there is no default.
SAMPLE_MTDIDS ??= ""

# If there is more than one mtdid, the mtdid that contains Sample.
# This should be the one after the equals sign in SAMPLE_MTDIDS.
# Currently there is no support for spreading over more than one.
SAMPLE_IS_ON_MTDID ??= "${@sample_default_sample_mtdid(d)}"

# The mtdparts string for the MTD layout. Usually auto-set from SAMPLE_MTDIDS
# if possible. It should contain a "u-boot" label and a "ubi" label.
SAMPLE_MTDPARTS ??= "${@sample_make_mtdparts(d)}"

# Usually included in first mtd partition.
SAMPLE_IMAGE_BOOTLOADER_FILE_DEFAULT_sample-ubi = "u-boot.${UBOOT_SUFFIX}"

################################################################################
# Most of the information about various Flash properties below has been grabbed
# from:
#   http://linux-mtd.infradead.org/doc/ubi.html
#     -and-
#   http://linux-mtd.infradead.org/doc/ubifs.html
#
# In particular, the UBI overhead information is very useful:
#   http://linux-mtd.infradead.org/doc/ubi.html#L_overhead
################################################################################

# Usually 2KiB, but can be other nearby powers of two.
SAMPLE_NAND_FLASH_PAGE_SIZE ??= "2048"

SAMPLE_FLASH_MINIMUM_IO_UNIT ??= "${@sample_flash_default_minimum_io_unit(d)}"

SAMPLE_UBI_LEB_PEB_BLOCK_OVERHEAD ??= "${@sample_calculate_ubi_leb_peb_block_overhead(d)}"

SAMPLE_UBI_LEB_SIZE ??= "${@eval('${SAMPLE_STORAGE_PEB_SIZE} - ${SAMPLE_UBI_LEB_PEB_BLOCK_OVERHEAD}')}"

# Fixed overhead which is the same for all UBI images.
# 2 PEBs are used to store the volume table;
# 1 PEB is reserved for wear-leveling purposes;
# 1 PEB is reserved for the atomic LEB change operation;
SAMPLE_UBI_TOTAL_FIXED_OVERHEAD ??= "${@eval('4 * ${SAMPLE_STORAGE_PEB_SIZE}')}"
# some amount of PEBs is reserved for bad PEB handling; this is applicable for
# NAND flash, but not for NOR flash; the amount of reserved PEBs is configurable
# and is equal to 20 blocks per 1024 blocks by default.
# The end result in the variables is expressed in bytes.
SAMPLE_UBI_TOTAL_BAD_PEB_OVERHEAD ??= "${@sample_get_ubi_bad_peb_overhead(d)}"
SAMPLE_UBI_TOTAL_LEB_PEB_OVERHEAD ??= "${@sample_calculate_ubi_leb_peb_overhead(d)}"

SAMPLE_MAXIMUM_LEB_COUNT ??= "1024"

MKUBIFS_ARGS ??= "-m ${SAMPLE_FLASH_MINIMUM_IO_UNIT} -e ${SAMPLE_UBI_LEB_SIZE} -c ${SAMPLE_MAXIMUM_LEB_COUNT}"
UBINIZE_ARGS ??= "-p ${SAMPLE_STORAGE_PEB_SIZE} -m ${SAMPLE_FLASH_MINIMUM_IO_UNIT} -s ${SAMPLE_FLASH_MINIMUM_IO_UNIT}"

# The volume numbers containing the two environment copies. The volume numbers
# are customizable because the kernel only accepts numbers, but U-boot only
# accepts names, and these are not currently customizable (see IMAGE_CMD_ubimg).
# Normally one does not need to set these unless there is a custom ubimg builder
# involved.
SAMPLE_UBOOT_ENV_UBIVOL_NUMBER_1 ??= "3"
SAMPLE_UBOOT_ENV_UBIVOL_NUMBER_2 ??= "4"

################################################################################
# Functions
################################################################################

def sample_warn_only_if_ubi(d, msg, fatal=False):
    if bb.utils.contains('DISTRO_FEATURES', 'sample-ubi', True, False, d):
        if fatal:
            bb.fatal(msg)
        else:
            bb.warn(msg)

def sample_default_sample_mtdid(d):
    mtdids = d.getVar("SAMPLE_MTDIDS")
    if mtdids is None or mtdids == "":
        sample_warn_only_if_ubi(d, "SAMPLE_MTDIDS must be defined", fatal=True)

    if len(mtdids.split(",")) == 1 and len(mtdids.split("=")) == 2:
        return mtdids.split("=")[1]
    else:
        # We don't know what to pick, choose nothing.
        return ""

def sample_make_mtdparts(d):
    mtdids = d.getVar('SAMPLE_MTDIDS')
    if not mtdids or len(mtdids.split(",")) > 1:
        return ""

    active_mtdid = d.getVar('SAMPLE_IS_ON_MTDID')
    if not active_mtdid:
        return ""

    u_boot_part_size = int(d.getVar('SAMPLE_STORAGE_PEB_SIZE'))
    # Default to at least 1MiB for U-Boot binary. Can be changed by setting
    # SAMPLE_MTDPARTS manually.
    if u_boot_part_size < 1048576:
        u_boot_part_size = 1048576

    bootloader = ""
    if bb.utils.contains('DISTRO_FEATURES', 'sample-uboot', True, False, d):
        bootloader = "%s(u-boot)ro," % sample_get_bytes_with_unit(u_boot_part_size)

    return "%s:%s-(%s)" % (active_mtdid, bootloader, d.getVar('SAMPLE_MTD_UBI_DEVICE_NAME'))

sample_get_mtdparts() {
    if [ -n "${SAMPLE_MTDPARTS}" ]; then
        echo "${SAMPLE_MTDPARTS}"
    else
        local mtdparts="${@sample_make_mtdparts(d)}"
        if [ -n "$mtdparts" ]; then
            echo "$mtdparts"
        else
            bbwarn "Unable to generate mtdparts. Make sure that SAMPLE_MTDIDS contains only one assignment, or, if this is not possible, set SAMPLE_IS_ON_MTDID and SAMPLE_MTDPARTS manually."
        fi
    fi
}

def sample_get_flash_type_from_mtdid(d):
    import re

    mtdid = d.getVar('SAMPLE_IS_ON_MTDID')
    match = re.search("([^=]+)=%s" % re.escape(mtdid), d.getVar('SAMPLE_MTDIDS'))
    if match is None:
        sample_warn_only_if_ubi(d, "Could not find SAMPLE_IS_ON_MTDID (%s) in SAMPLE_MTDIDS (%s)."
                                % (mtdid, d.getVar('SAMPLE_MTDIDS')))
        return ""
    storage = match.group(1)
    # Get rid of trailing numbers.
    storage = re.sub("[0-9]*$", "", storage)

    if storage == "onenand":
        return "nand"
    else:
        return storage

def sample_calculate_ubi_leb_peb_block_overhead(d):
    storage = sample_get_flash_type_from_mtdid(d)

    # See http://linux-mtd.infradead.org/doc/ubi.html#L_overhead
    if storage == "nor":
        return "128"
    elif storage == "nand":
        return str(int(d.getVar('SAMPLE_NAND_FLASH_PAGE_SIZE')) * 2)
    else:
        sample_warn_only_if_ubi(d, "Unknown MTDID type %s, setting UBI block overhead to 0" % storage)
        return "0"

def sample_get_ubi_size(d):
    import re

    mtdid = d.getVar('SAMPLE_IS_ON_MTDID')
    mtdparts = d.getVar('SAMPLE_MTDPARTS')
    for part in mtdparts.split(";"):
        if part.startswith("%s:" % mtdid):
            mtdpart = part
            break
    else:
        sample_warn_only_if_ubi(d, "Could not find SAMPLE_IS_ON_MTDID (%s) in SAMPLE_MTDPARTS (%s). Returning UBI size of zero."
                                % (mtdid, mtdparts))
        return 0

    # Find all space in mtdimage not occupied by the UBI image.
    non_ubi_size = 0
    ubiname = d.getVar('SAMPLE_MTD_UBI_DEVICE_NAME')
    for part in mtdpart.split(":", 1)[1].split(","):
        match = re.match("^([0-9]+|-)([kmg]?)(?:@([0-9]+)([kmg]?))?\(([^)]+)\)", part)
        if match is None:
            bb.fatal("Unable to parse mtdparts substring '%s'." % part)
        if match.group(3):
            non_ubi_size = sample_mtdparts_convert_units_to_bytes(match.group(3), match.group(4))
        if match.group(1) == "-":
            vol_size = "-"
        else:
            vol_size = sample_mtdparts_convert_units_to_bytes(match.group(1), match.group(2))

        if match.group(5) == ubiname:
            # UBI space, we are finished.
            break

        if vol_size != "-":
            non_ubi_size += vol_size
    else:
        bb.fatal("Could not find \"(%s)\" MTD partition" % ubiname)

    if vol_size == "-":
        ubi_size = int(d.getVar('SAMPLE_STORAGE_TOTAL_SIZE_MB')) * 1048576 - non_ubi_size
    else:
        ubi_size = vol_size

    return ubi_size

def sample_calculate_ubi_leb_peb_overhead(d):
    # In addition to the overhead caused by alignment, we also need to take into
    # account that UBI LEBs (logical erase blocks) are smaller than PEBs
    # (physical erase blocks), so the whole UBI storage has less capacity than
    # its actual blocks.
    ubi_size = sample_get_ubi_size(d)
    peb_size = int(d.getVar('SAMPLE_STORAGE_PEB_SIZE'))
    leb_size = int(d.getVar('SAMPLE_UBI_LEB_SIZE'))
    overhead = (peb_size - leb_size) * int(ubi_size / peb_size)
    return str(overhead)

def sample_get_ubi_bad_peb_overhead(d):
    import math

    storage = sample_get_flash_type_from_mtdid(d)

    if storage == "nor":
        return "0"
    elif storage == "nand":
        ubi_size = sample_get_ubi_size(d)
        peb_size = int(d.getVar('SAMPLE_STORAGE_PEB_SIZE'))
        blocks = int(ubi_size / peb_size)
        bad_blocks = int(math.ceil(blocks / 1024) * 20)
        return str(bad_blocks * peb_size)
    else:
        sample_warn_only_if_ubi(d, "Unknown MTDID type %s, setting UBI overhead to 0" % storage)
        return "0"

def sample_get_partitioning_overhead_kb_ubi(d):
    fixed = int(d.getVar('SAMPLE_UBI_TOTAL_FIXED_OVERHEAD'))
    bad = int(d.getVar('SAMPLE_UBI_TOTAL_BAD_PEB_OVERHEAD'))
    leb_peb = int(d.getVar('SAMPLE_UBI_TOTAL_LEB_PEB_OVERHEAD'))
    ubi_size = sample_get_ubi_size(d)
    total_size = int(d.getVar('SAMPLE_STORAGE_TOTAL_SIZE_MB')) * 1048576

    overhead = fixed + bad + leb_peb
    # Anything which is not in the UBI section is essentially overhead.
    overhead += total_size - ubi_size

    # Overhead must be rounded to nearest alignment.
    alignment = int(d.getVar('SAMPLE_PARTITION_ALIGNMENT'))
    overhead = alignment * (int((overhead - 1) / alignment) + 1)
    return str(int(overhead / 1024))

def sample_flash_default_minimum_io_unit(d):
    flash_type = sample_get_flash_type_from_mtdid(d)
    if flash_type == "nand":
        return d.getVar("SAMPLE_NAND_FLASH_PAGE_SIZE")
    elif flash_type == "nor":
        return "1"
    else:
        # This is just a guess, really.
        return "512"
