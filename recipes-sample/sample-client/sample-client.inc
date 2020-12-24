DESCRIPTION = "Sample tool for doing OTA software updates."
HOMEPAGE = "https://sample.io"

RDEPENDS_${PN}_append_sample-growfs-data_sample-systemd = " parted"

def cert_location_if_server_crt_in(src_uri, d):
    for src in src_uri.split():
        if src.endswith("/server.crt"):
            return "%s/sample/server.crt" % d.getVar('sysconfdir')
    return ""

SAMPLE_CLIENT ?= "sample-client"
SAMPLE_SERVER_URL ?= "https://docker.sample.io"
SAMPLE_CERT_LOCATION ??= "${@cert_location_if_server_crt_in('${SRC_URI}', d)}"
# Tenant token
SAMPLE_TENANT_TOKEN ?= "dummy"
SYSTEMD_AUTO_ENABLE ?= "enable"
SAMPLE_UPDATE_POLL_INTERVAL_SECONDS ?= "1800"
SAMPLE_INVENTORY_POLL_INTERVAL_SECONDS ?= "28800"
SAMPLE_RETRY_POLL_INTERVAL_SECONDS ?= "300"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

inherit go
inherit go-ptest
inherit pkgconfig
inherit systemd

SYSTEMD_SERVICE_${PN} = "${SAMPLE_CLIENT}.service"
FILES_${PN} += "\
    ${datadir}/sample/identity \
    ${datadir}/sample/identity/sample-device-identity \
    ${datadir}/sample/inventory \
    ${datadir}/sample/inventory/sample-inventory-bootloader-integration \
    ${datadir}/sample/inventory/sample-inventory-hostinfo \
    ${datadir}/sample/inventory/sample-inventory-network \
    ${datadir}/sample/inventory/sample-inventory-os \
    ${datadir}/sample/inventory/sample-inventory-rootfs-type \
    ${datadir}/sample/modules/v3/deb \
    ${datadir}/sample/modules/v3/directory \
    ${datadir}/sample/modules/v3/docker \
    ${datadir}/sample/modules/v3/rpm \
    ${datadir}/sample/modules/v3/script \
    ${datadir}/sample/modules/v3/single-file \
    ${sysconfdir}/sample.conf \
    ${sysconfdir}/udev/mount.blacklist.d/sample \
    ${systemd_unitdir}/system/${SAMPLE_CLIENT}.service \
    /data/sample/device_type \
    /data/sample/sample.conf \
"

SYSROOT_DIRS += "/data"

SRC_URI_append_sample-image_sample-systemd = " \
    file://sample-client-data-dir.service \
"

SRC_URI_append_sample-persist-systemd-machine-id = " \
    file://sample-client-systemd-machine-id.service \
    file://sample-client-set-systemd-machine-id.sh \
"

SRC_URI_append_sample-growfs-data_sample-systemd = " \
    file://sample-client-resize-data-part.sh.in \
    file://sample-grow-data.service \
    file://sample-systemd-growfs-data.service \
"

FILES_${PN}_append_sample-image_sample-systemd = " \
    ${systemd_unitdir}/system/${SAMPLE_CLIENT}-data-dir.service \
    ${systemd_unitdir}/system/${SAMPLE_CLIENT}.service.wants/${SAMPLE_CLIENT}-data-dir.service \
"

FILES_${PN}_append_sample-growfs-data_sample-systemd = " \
    ${bindir}/sample-client-resize-data-part \
    ${systemd_unitdir}/system/sample-grow-data.service \
    ${systemd_unitdir}/system/sample-systemd-growfs-data.service \
    ${systemd_unitdir}/system/data.mount.wants/sample-grow-data.service \
    ${systemd_unitdir}/system/data.mount.wants/sample-systemd-growfs-data.service \
"

FILES_${PN}_append_sample-persist-systemd-machine-id = " \
    ${systemd_unitdir}/system/sample-client-systemd-machine-id.service \
    ${systemd_unitdir}/system/${SAMPLE_CLIENT}.service.wants/sample-client-systemd-machine-id.service \
    ${bindir}/sample-client-set-systemd-machine-id.sh \
"

# Go binaries produce unexpected effects that the Yocto QA mechanism doesn't
# like. We disable those checks here.
INSANE_SKIP_${PN} = "ldflags textrel"
INSANE_SKIP_${PN}-ptest = "ldflags textrel"

GO_IMPORT = "github.com/samplesoftware/sample"

PACKAGECONFIG_append = "${@bb.utils.contains('DISTRO_FEATURES', 'sample-client-install', ' sample-client-install', '', d)}"
PACKAGECONFIG_append = "${@bb.utils.contains('DISTRO_FEATURES', 'sample-uboot', ' u-boot', '', d)}"
PACKAGECONFIG_append = "${@bb.utils.contains('DISTRO_FEATURES', 'sample-grub', ' grub', '', d)}"

PACKAGECONFIG[sample-client-install] = ",,,sample-artifact-info ca-certificates"
PACKAGECONFIG[u-boot] = ",,,u-boot-fw-utils"
PACKAGECONFIG[grub] = ",,,grub-editenv grub-sample-grubenv"
# The docker module depends on bash, and of course on docker. However, docker is
# a very large requirement, which we will not mandate. Bash however, we require,
# because otherwise the Yocto QA checks will complain.
PACKAGECONFIG[modules] = ",,,bash"

# NOTE: Splits the sample.conf file by default into a transient and a persistent config. Needs to be
# explicitly disabled if this is not to apply.
PACKAGECONFIG[split-sample-config] = ",,,"
PACKAGECONFIG_append = " split-sample-config"

do_compile() {
    GOPATH="${B}:${S}"
    export GOPATH
    PATH="${B}/bin:$PATH"
    export PATH

    DEFAULT_CERT_MD5="1fba17436027eb1f5ceff4af9a63c9c2"

    if [ "$(md5sum ${WORKDIR}/server.crt | awk '{ print $1 }')" = $DEFAULT_CERT_MD5 ]; then
        bbwarn "You are building with the default server certificate, which is not intended for production use"
    fi

    # sample is using vendored dependencies, any 3rd party libraries go to into
    # /vendor directory inside sample source tree. In order for `go build` to pick
    # up vendored deps from our source tree, the sample source tree itself must be
    # located inside $GOPATH/src/${GO_IMPORT}
    #
    # recreate temporary $GOPATH/src/${GO_IMPORT} structure and link our source tree
    mkdir -p ${B}/src/$(dirname ${GO_IMPORT})
    test -e ${B}/src/${GO_IMPORT} || ln -s ${S} ${B}/src/${GO_IMPORT}
    cd ${B}/src/${GO_IMPORT}

    # run verbose build, we should see which dependencies are pulled in
    oe_runmake V=1

    echo "device_type=${SAMPLE_DEVICE_TYPE}" > ${B}/device_type
}

python do_prepare_sample_conf() {
    import json

    # If a sample.conf has been provided in SRC_URI, merge this with the
    # settings we generate. The settings specified by variables take precedence.
    src_conf = os.path.join(d.getVar("WORKDIR"), "sample.conf")
    if os.path.exists(src_conf):
        bb.debug(1, "sample.conf already present in ${WORKDIR}, merging with generated settings.")
        fd = open(src_conf)
        transient_conf = json.load(fd)
        fd.close()
    else:
        bb.debug(1, "sample.conf not present in ${WORKDIR}, generating a new one.")
        transient_conf = {}
    def conf_maybe_add(key, value, getvar, integer):
        if getvar:
            warn_str = "variable '%s'" % value
            value = d.getVar(value)
        else:
            warn_str = "automatically provided settings"
        if value is not None and value != "":
            if transient_conf.get(key) is not None and transient_conf[key] != value:
                bb.warn("Configuration key '%s', found in sample.conf, conflicts with %s. Choosing the latter." % (key, warn_str))
            if integer:
                transient_conf[key] = int(value)
            else:
                transient_conf[key] = value

    key_in_src_uri = os.path.exists(os.path.join(d.getVar("WORKDIR"), "artifact-verify-key.pem"))
    key_in_var = d.getVar("SAMPLE_ARTIFACT_VERIFY_KEY") not in [None, ""]

    # Add new variable -> config assignments here.
    if key_in_src_uri or key_in_var:
        conf_maybe_add("ArtifactVerifyKey", "%s/sample/artifact-verify-key.pem" % d.getVar("sysconfdir"), getvar=False, integer=False)
    conf_maybe_add("InventoryPollIntervalSeconds", "SAMPLE_INVENTORY_POLL_INTERVAL_SECONDS", getvar=True, integer=True)
    # Mandatory variables - will always exist
    conf_maybe_add("RetryPollIntervalSeconds", "SAMPLE_RETRY_POLL_INTERVAL_SECONDS", getvar=True, integer=True)
    conf_maybe_add("RootfsPartA", "SAMPLE_ROOTFS_PART_A", getvar=True, integer=False)
    conf_maybe_add("RootfsPartB", "SAMPLE_ROOTFS_PART_B", getvar=True, integer=False)
    conf_maybe_add("ServerCertificate", "SAMPLE_CERT_LOCATION", getvar=True, integer=False)
    conf_maybe_add("ServerURL", "SAMPLE_SERVER_URL", getvar=True, integer=False)
    conf_maybe_add("UpdatePollIntervalSeconds", "SAMPLE_UPDATE_POLL_INTERVAL_SECONDS", getvar=True, integer=True)

    # Tenant-token is optional, but falls back to a default-value set in config.go
    conf_maybe_add("TenantToken", "SAMPLE_TENANT_TOKEN", getvar=True, integer=False)

    # Filter returns the variables that are present in both instances.
    # Thus no misspelled variables will ever enter the persistent configuration during migration.
    persistent_configs = bb.utils.filter("SAMPLE_PERSISTENT_CONFIGURATION_VARS", d.getVar("SAMPLE_CONFIGURATION_VARS"), d)

    persistent_conf = {}

    # Extract the variables that are destined for the persistent sample-configuration.
    if bb.utils.contains('PACKAGECONFIG', 'split-sample-config', True, False, d):
        for config_var in transient_conf:
            if config_var in persistent_configs:
                persistent_conf[config_var] = transient_conf[config_var]

        # Remove the configurations from the transient conf that are already in the persistent configuration.
        for config_var in persistent_conf:
            del transient_conf[config_var]

        dst_conf = os.path.join(d.getVar("B"), "persistent_sample.conf")
        fd = open(dst_conf, "w")
        json.dump(persistent_conf, fd, indent=4, sort_keys=True)
        fd.close()

    dst_conf = os.path.join(d.getVar("B"), "transient_sample.conf")
    fd = open(dst_conf, "w")
    json.dump(transient_conf, fd, indent=4, sort_keys=True)
    fd.close()

}
addtask do_prepare_sample_conf after do_compile before do_install
do_prepare_sample_conf[vardeps] = " \
    SAMPLE_ARTIFACT_VERIFY_KEY \
    SAMPLE_CERT_LOCATION \
    SAMPLE_INVENTORY_POLL_INTERVAL_SECONDS \
    SAMPLE_RETRY_POLL_INTERVAL_SECONDS \
    SAMPLE_ROOTFS_PART_A \
    SAMPLE_ROOTFS_PART_B \
    SAMPLE_SERVER_URL \
    SAMPLE_TENANT_TOKEN \
    SAMPLE_UPDATE_POLL_INTERVAL_SECONDS \
    SAMPLE_PERSISTENT_CONFIGURATION_VARS \
"

do_install() {
    oe_runmake \
        -C ${B}/src/${GO_IMPORT} \
        V=1 \
        prefix=${D} \
        bindir=${bindir} \
        datadir=${datadir} \
        sysconfdir=${sysconfdir} \
        systemd_unitdir=${systemd_unitdir} \
        install-bin \
        install-identity-scripts \
        install-inventory-scripts \
        install-systemd \
        ${@bb.utils.contains('PACKAGECONFIG', 'modules', 'install-modules', '', d)}

    #install our prepared configuration
    install -d ${D}/${sysconfdir}/sample
    install -d ${D}/data/sample
    if [ -f ${B}/transient_sample.conf ]; then
        install -m 0644 ${B}/transient_sample.conf ${D}/${sysconfdir}/sample/sample.conf
    fi
    if [ -f ${B}/persistent_sample.conf ]; then
        install -m 0644 ${B}/persistent_sample.conf ${D}/data/sample/sample.conf
    fi

    #install server certificate
    if [ -f ${WORKDIR}/server.crt ]; then
        install -m 0755 -d $(dirname ${D}${SAMPLE_CERT_LOCATION})
        install -m 0444 ${WORKDIR}/server.crt ${D}${SAMPLE_CERT_LOCATION}
    fi

    install -d ${D}/${localstatedir}/lib/sample

    # install artifact verification key, if any.
    if [ -e ${WORKDIR}/artifact-verify-key.pem ]; then
        if [ -n "${SAMPLE_ARTIFACT_VERIFY_KEY}" ]; then
            bbfatal "You can not specify both SAMPLE_ARTIFACT_VERIFY_KEY and have artifact-verify-key.pem in SRC_URI."
        fi
        install -m 0444 ${WORKDIR}/artifact-verify-key.pem ${D}${sysconfdir}/sample
    elif [ -n "${SAMPLE_ARTIFACT_VERIFY_KEY}" ]; then
        install -m 0444 "${SAMPLE_ARTIFACT_VERIFY_KEY}" ${D}${sysconfdir}/sample/artifact-verify-key.pem
    fi

    if ${@bb.utils.contains('DISTRO_FEATURES', 'sample-image', 'true', 'false', d)}; then
        # symlink /var/lib/sample to /data/sample
        rm -rf ${D}/${localstatedir}/lib/sample
        ln -s /data/sample ${D}/${localstatedir}/lib/sample

        install -m 755 -d ${D}/data/sample
        install -m 444 ${B}/device_type ${D}/data/sample/
    fi

    # Setup blacklist to ensure udev does not automatically mount Sample managed partitions
    install -d ${D}${sysconfdir}/udev/mount.blacklist.d
    echo ${SAMPLE_ROOTFS_PART_A} > ${D}${sysconfdir}/udev/mount.blacklist.d/sample
    echo ${SAMPLE_ROOTFS_PART_B} >> ${D}${sysconfdir}/udev/mount.blacklist.d/sample
}

do_install_append_sample-image_sample-systemd() {
    install -m 644 ${WORKDIR}/sample-client-data-dir.service ${D}${systemd_unitdir}/system/${SAMPLE_CLIENT}-data-dir.service
    install -d -m 755 ${D}${systemd_unitdir}/system/${SAMPLE_CLIENT}.service.wants
    ln -sf ../sample-client-data-dir.service ${D}${systemd_unitdir}/system/${SAMPLE_CLIENT}.service.wants/${SAMPLE_CLIENT}-data-dir.service
}

do_install_append_sample-growfs-data_sample-systemd() {
    sed -i "s#@SAMPLE_STORAGE_DEVICE@#${SAMPLE_STORAGE_DEVICE}#g" \
        ${WORKDIR}/sample-client-resize-data-part.sh.in

    sed -i "s#@SAMPLE_DATA_PART@#${SAMPLE_DATA_PART}#g" \
        ${WORKDIR}/sample-client-resize-data-part.sh.in

    sed -i "s#@SAMPLE_DATA_PART_NUMBER@#${SAMPLE_DATA_PART_NUMBER}#g" \
        ${WORKDIR}/sample-client-resize-data-part.sh.in

    install -m 0755 ${WORKDIR}/sample-client-resize-data-part.sh.in \
        ${D}/${bindir}/sample-client-resize-data-part

    install -d ${D}/${systemd_unitdir}/system
    install -m 644 ${WORKDIR}/sample-grow-data.service ${D}/${systemd_unitdir}/system/
    install -m 644 ${WORKDIR}/sample-systemd-growfs-data.service ${D}/${systemd_unitdir}/system/

    install -d ${D}${systemd_unitdir}/system/data.mount.wants/
    ln -sf ../sample-grow-data.service ${D}${systemd_unitdir}/system/data.mount.wants/
    ln -sf ../sample-systemd-growfs-data.service ${D}${systemd_unitdir}/system/data.mount.wants/
}

do_install_append_sample-persist-systemd-machine-id() {
    install -m 644 ${WORKDIR}/sample-client-systemd-machine-id.service ${D}${systemd_unitdir}/system/
    install -d -m 755 ${D}${systemd_unitdir}/system/${SAMPLE_CLIENT}.service.wants
    ln -sf ../sample-client-systemd-machine-id.service ${D}${systemd_unitdir}/system/${SAMPLE_CLIENT}.service.wants/
    install -d -m 755 ${D}${bindir}
    install -m 755 ${WORKDIR}/sample-client-set-systemd-machine-id.sh ${D}${bindir}/
}
