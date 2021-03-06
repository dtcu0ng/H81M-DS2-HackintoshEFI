#!/bin/bash
download_bootloader() {
    echo Cleaning up current EFI...
    rm -rf EFI
    RELEASE_URL=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/acidanthera/OpenCorePkg/releases/latest)
    TAG="${RELEASE_URL##*/}"
    url=https://github.com/acidanthera/OpenCorePkg/releases/download/$TAG/OpenCore-$TAG-$TARGET.zip
    echo Downloading OpenCore $TAG $TARGET
    curl -# -L -O "${url}" || exit 1
    unzip -qq "*.zip" || exit 1
    echo "Installed OpenCore version $TAG ($TARGET) and kexts in CI#$GITHUB_RUN_NUMBER for commit $GITHUB_SHA:" >> installed_compoments.txt
}

make_efi() {
    echo Making standard OpenCore EFI folder...
    cd X64/EFI/OC
    cd Drivers
    find . ! -name OpenRuntime.efi -delete
    cd ../Tools
    find . ! -name OpenShell.efi -delete
    cd ../../../..
    cp -R X64/EFI EFI
}

copy_stuff() {
    echo Copying SSDTs...
    cp ACPI/SSDT-EC.aml EFI/OC/ACPI
    cp ACPI/SSDT-PLUG.aml EFI/OC/ACPI
    echo Copying OpenCore config...
    cp config/config_igpu.plist EFI/OC
    cp config/config.plist EFI/OC
    cp config/CONFIG_README.txt EFI/OC
    echo Copying HFS driver...
    cp Drivers/HfsPlus.efi EFI/OC/Drivers
    cp installed_compoments.txt EFI/OC
}

cleanup() {
    echo Cleaning up...
    rm -r Docs
    rm -r IA32
    rm -r Utilities
    rm -r X64
    rm OpenCore-$TAG-$TARGET.zip
}

main() {
    download_bootloader
    make_efi
    copy_stuff
    cleanup
}

main