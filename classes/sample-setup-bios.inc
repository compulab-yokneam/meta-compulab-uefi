# Make sure that GRUB is flashed to first non-partition table sector.
SAMPLE_IMAGE_BOOTLOADER_FILE_DEFAULT_sample-grub_sample-bios = "grub-core.img"
SAMPLE_IMAGE_BOOTLOADER_BOOTSECTOR_OFFSET_DEFAULT_sample-grub_sample-bios_sample-image-bios = "1"

# The first non-partition table sector of GPT is 34.
# https://en.wikipedia.org/wiki/GUID_Partition_Table
SAMPLE_IMAGE_BOOTLOADER_BOOTSECTOR_OFFSET_DEFAULT_sample-grub_sample-bios_sample-image-gpt = "34"

# And that the 1st stage bootloader is in the MBR.
SAMPLE_MBR_BOOTLOADER_FILE_DEFAULT_sample-grub_sample-bios = "boot.img"

EXTRA_IMAGEDEPENDS_append_sample-grub_sample-bios = " grub"
