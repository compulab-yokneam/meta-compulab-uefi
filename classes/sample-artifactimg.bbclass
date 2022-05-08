inherit sample-helpers

# ------------------------------ CONFIGURATION ---------------------------------

# Extra arguments that should be passed to sample-artifact.
SAMPLE_ARTIFACT_EXTRA_ARGS ?= ""

# The key used to sign the sample update.
SAMPLE_ARTIFACT_SIGNING_KEY ?= ""

# --------------------------- END OF CONFIGURATION -----------------------------

do_image_sample[depends] += "sample-artifact-native:do_populate_sysroot"

ARTIFACTIMG_FSTYPE ??= "${ARTIFACTIMG_FSTYPE_DEFAULT}"
ARTIFACTIMG_FSTYPE_DEFAULT = "ext4"

ARTIFACTIMG_NAME ??= "${ARTIFACTIMG_NAME_DEFAULT}"
ARTIFACTIMG_NAME_DEFAULT = "${IMAGE_LINK_NAME}"

SAMPLE_ARTIFACT_NAME_DEPENDS ?= ""

SAMPLE_ARTIFACT_PROVIDES ?= ""
SAMPLE_ARTIFACT_PROVIDES_GROUP ?= ""

SAMPLE_ARTIFACT_DEPENDS ?= ""
SAMPLE_ARTIFACT_DEPENDS_GROUPS ?= ""

apply_arguments () {
    #
    # $1 -- the command line flag to apply to each element
    # $@ -- the list of arguments to give each its own flag
    #
    local res=""
    flag=$1
    shift
    for arg in $@; do
        res="$res $flag $arg"
    done
    cmd=$res
}

IMAGE_CMD_sample () {
    set -x

    if [ -z "${SAMPLE_ARTIFACT_NAME}" ]; then
        bbfatal "Need to define SAMPLE_ARTIFACT_NAME variable."
    fi

    rootfs_size=$(stat -Lc %s ${IMGDEPLOYDIR}/${ARTIFACTIMG_NAME}.${ARTIFACTIMG_FSTYPE})
    calc_rootfs_size=$(expr ${SAMPLE_CALC_ROOTFS_SIZE} \* 1024)
    if [ $rootfs_size -gt $calc_rootfs_size ]; then
        bbfatal "Size of rootfs is greater than the calculated partition space ($rootfs_size > $calc_rootfs_size). This image won't fit on a device with the current storage configuration. Try reducing IMAGE_OVERHEAD_FACTOR if it is higher than 1.0, or raise SAMPLE_STORAGE_TOTAL_SIZE_MB if the device in fact has more storage."
    fi

    if [ -z "${SAMPLE_DEVICE_TYPES_COMPATIBLE}" ]; then
        bbfatal "SAMPLE_DEVICE_TYPES_COMPATIBLE variable cannot be empty."
    fi

    extra_args=

    for dev in ${SAMPLE_DEVICE_TYPES_COMPATIBLE}; do
        extra_args="$extra_args -t $dev"
    done

    if [ -n "${SAMPLE_ARTIFACT_SIGNING_KEY}" ]; then
        extra_args="$extra_args -k ${SAMPLE_ARTIFACT_SIGNING_KEY}"
    fi

    if [ -d "${DEPLOY_DIR_IMAGE}/sample-state-scripts" ]; then
        extra_args="$extra_args -s ${DEPLOY_DIR_IMAGE}/sample-state-scripts"
    fi

    if sample-artifact write rootfs-image --help | grep -e '-u FILE'; then
        image_flag=-u
    else
        image_flag=-f
    fi

    if [ -n "${SAMPLE_ARTIFACT_NAME_DEPENDS}" ]; then
        cmd=""
        apply_arguments "--artifact-name-depends" "${SAMPLE_ARTIFACT_NAME_DEPENDS}"
        extra_args="$extra_args  $cmd"
    fi

    if [ -n "${SAMPLE_ARTIFACT_PROVIDES}" ]; then
        cmd=""
        apply_arguments "--provides" "${SAMPLE_ARTIFACT_PROVIDES}"
        extra_args="$extra_args  $cmd"
    fi

    if [ -n "${SAMPLE_ARTIFACT_PROVIDES_GROUP}" ]; then
        cmd=""
        apply_arguments "--provides-group" "${SAMPLE_ARTIFACT_PROVIDES_GROUP}"
        extra_args="$extra_args $cmd"
    fi

    if [ -n "${SAMPLE_ARTIFACT_DEPENDS}" ]; then
        cmd=""
        apply_arguments "--depends" "${SAMPLE_ARTIFACT_DEPENDS}"
        extra_args="$extra_args $cmd"
    fi

    if [ -n "${SAMPLE_ARTIFACT_DEPENDS_GROUPS}" ]; then
        cmd=""
        apply_arguments "--depends-groups" "${SAMPLE_ARTIFACT_DEPENDS_GROUPS}"
        extra_args="$extra_args $cmd"
    fi

    sample-artifact write rootfs-image \
        -n ${SAMPLE_ARTIFACT_NAME} \
        $extra_args \
        $image_flag ${IMGDEPLOYDIR}/${ARTIFACTIMG_NAME}.${ARTIFACTIMG_FSTYPE} \
        ${SAMPLE_ARTIFACT_EXTRA_ARGS} \
        -o ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.sample
}

IMAGE_CMD_sample[vardepsexclude] += "IMAGE_ID"
# We need to have the filesystem image generated already.
IMAGE_TYPEDEP_sample:append = " ${ARTIFACTIMG_FSTYPE}"
