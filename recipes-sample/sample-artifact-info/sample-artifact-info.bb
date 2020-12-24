DESCRIPTION = "Sample artifact information"
HOMEPAGE = "https://sample.io"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

FILESPATH = "${COMMON_LICENSE_DIR}"
SRC_URI = "file://Apache-2.0"

S = "${WORKDIR}"

inherit allarch

PV = "0.1"

do_compile() {
    if [ -z "${SAMPLE_ARTIFACT_NAME}" ]; then
        bberror "Need to define SAMPLE_ARTIFACT_NAME variable."
        exit 1
    fi

    cat > ${B}/artifact_info << END
artifact_name=${SAMPLE_ARTIFACT_NAME}
END
}

do_install() {
    install -d ${D}${sysconfdir}/sample
    install -m 0644 -t ${D}${sysconfdir}/sample ${B}/artifact_info
}

FILES_${PN} += " \
    ${sysconfdir}/sample/artifact_info \
"
