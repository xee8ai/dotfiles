#!/bin/bash

MODULES="
nvidia-uvm.ko
nvidia-peermem.ko
nvidia-modeset.ko
nvidia.ko
nvidia-drm.ko
"

for VERSION in $(ls -1 /lib/modules); do
    echo
    # SHORT_VERSION=$(echo $VERSION | cut -d . -f 1-2)
    SHORT_VERSION=$(echo $VERSION | cut -d"-" -f 1)
    MODULES_DIR=/lib/modules/$VERSION/updates/dkms
    KBUILD_DIR=/usr/lib/linux-kbuild-$SHORT_VERSION

    echo "Signing modules in $MODULES_DIR"

    cd $MODULES_DIR
    for MODULE in $(ls -1); do
        echo "Signing $MODULE"
        $KBUILD_DIR/scripts/sign-file sha256 /etc/MOK.priv /etc/MOK.der $MODULE
    done
done

echo
echo "Updating initramfs"
update-initramfs -k all -u
