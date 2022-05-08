do_configure:append() {
    echo "CONFIG_EFI=y" >> ${B}/.config
}
