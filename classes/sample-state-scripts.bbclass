inherit deploy

SAMPLE_STATE_SCRIPTS_DIR = "${B}/sample-state-scripts"

# Default is to look in these two directories for scripts.
SAMPLE_STATE_SCRIPTS ?= "${S}/sample-state-scripts ${SAMPLE_STATE_SCRIPTS_DIR}"

do_create_default_script_dirs() {
    # Doing this automatically has two advantages: The user can install directly
    # into the directories with no preparation. And, we can complain if any of
    # the targets in SAMPLE_STATE_SCRIPTS doesn't exist, because a directory
    # that exists, but is empty, is different from not existing at all.

    mkdir -p ${S}/sample-state-scripts ${B}/sample-state-scripts
}
addtask do_create_default_script_dirs after do_patch before do_configure

# Takes one argument, which is "install" or "deploy".
install_or_deploy_scripts() {
    case "$1" in
        install|deploy)
            ;;
        *)
            bbfatal "Internal error: Argument is not install or deploy"
            ;;
    esac
    action=$1

    for entry in ${SAMPLE_STATE_SCRIPTS}; do
        if [ ! -e "$entry" ]; then
            bbfatal "$entry from SAMPLE_STATE_SCRIPTS does not exist"
        fi
    done

    # Use "sort -u" below to get rid of duplicates which can often happen if
    # ${B} and ${S} are the same.
    for script in $(find ${SAMPLE_STATE_SCRIPTS} -type f | sort -u); do
        case "$(basename "$script")" in
            Artifact*)
                if [ $action = install ]; then
                    # Ignore Artifact scripts for install action, since they
                    # don't go to the rootfs.
                    continue
                fi

                # Artifact scripts should be in the .sample file and go
                # to the deploy section.
                install -d -m 755 ${DEPLOYDIR}/sample-state-scripts/
                install -m 755 "$script" ${DEPLOYDIR}/sample-state-scripts/
                ;;
            *)
                if [ $action = deploy ]; then
                    # Non Artifact scripts go to rootfs, so ignore for
                    # deploy action.
                    continue
                fi

                # Non-Artifact scripts should be installed in rootfs.
                case "$(basename "$script")" in
                    Idle*|Sync*|Download*)
                        ;;
                    *)
                        bbfatal "$script script doesn't have a valid name."
                        ;;
                esac
                install -d -m 755 ${D}${sysconfdir}/sample/scripts/
                install -m 755 "$script" ${D}${sysconfdir}/sample/scripts/
                ;;
        esac
    done
}

do_install_append() {
    install_or_deploy_scripts install
}

# Provide default, empty do_deploy.
do_deploy() {
}
addtask do_deploy after do_compile

# Add our own deploy steps.
do_deploy_append() {
    install_or_deploy_scripts deploy
}
