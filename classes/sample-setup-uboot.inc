EXTRA_IMAGEDEPENDS_append = "${@bb.utils.contains('DISTRO_FEATURES', 'sample-uboot', ' u-boot', '', d)}"


def sample_get_env_total_aligned_size(bootenv_size, alignment_bytes):
    env_aligned_size = int((bootenv_size + alignment_bytes - 1) / alignment_bytes) * alignment_bytes

    # Total size, original and redundant environment.
    total_env_size = env_aligned_size * 2

    return "%d" % total_env_size

SAMPLE_UBOOT_ENV_STORAGE_DEVICE_OFFSET ??= "${SAMPLE_PARTITION_ALIGNMENT}"

# The total occupied length of the environment on disk, after alignment has been
# taken into account. This is a guesstimate, and will be matched against the
# real size in the U-Boot recipe later. Must be an *even* multiple of the
# alignment. Most people should not need to set this, and if so, only because it
# produces an error if left to the default.
SAMPLE_RESERVED_SPACE_BOOTLOADER_DATA_DEFAULT_sample-uboot = \
    "${@sample_get_env_total_aligned_size(${SAMPLE_PARTITION_ALIGNMENT}, \
                                          ${SAMPLE_PARTITION_ALIGNMENT})}"

# make sure to provide a weak default
UBOOT_SUFFIX ??= "bin"

# Prefer to use our auto provided fw-utils variant which duplicates the sources
# from u-boot, so we don't have to apply the same patches twice.
PREFERRED_PROVIDER_u-boot-fw-utils ??= "${@sample_check_distro_features_early_contains(d, \
                                                                                       'sample-uboot', \
                                                                                       'u-boot-fw-utils-sample-auto-provided', \
                                                                                       '')}"
PREFERRED_RPROVIDER_u-boot-fw-utils ??= "${@sample_check_distro_features_early_contains(d, \
                                                                                        'sample-uboot', \
                                                                                        'u-boot-fw-utils-sample-auto-provided', \
                                                                                        '')}"

def sample_check_distro_features_early_contains(d, feature, if_true, if_false):
    # Why this complicated function instead of checking DISTRO_FEATURES
    # directly? It's because PREFERRED_PROVIDERs have some special early
    # handling which happens before DISTRO_FEATURES is resolved, so we need to
    # do this special early check.

    in_df_backfill = bb.utils.contains('DISTRO_FEATURES_BACKFILL', feature, True, False, d)
    in_df_backfill_considered = bb.utils.contains('DISTRO_FEATURES_BACKFILL_CONSIDERED', feature, True, False, d)

    if in_df_backfill and not in_df_backfill_considered:
        return if_true
    else:
        return if_false
