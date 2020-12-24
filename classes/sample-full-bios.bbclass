# Class for those who want to enable all Sample required features for BIOS based
# boards.

SAMPLE_FEATURES_ENABLE_append = " \
    sample-image \
    sample-client-install \
    sample-systemd \
"

SAMPLE_FEATURES_ENABLE_append_x86 = " sample-image-bios sample-grub sample-bios"
SAMPLE_FEATURES_ENABLE_append_x86-64 = " sample-image-bios sample-grub sample-bios"
