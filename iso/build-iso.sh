#!/bin/bash
# build-iso.sh — Lychee OS Master ISO builder
set -euo pipefail

DISTRO="Lychee OS"
VERSION=$(date +%Y.%m)
ARCH=${1:-x86_64}
OUTDIR="$PWD/output"
WORK="$PWD/work/$ARCH"

mkdir -pv "$WORK"/{airootfs,efi,isolinux}
mkdir -pv "$OUTDIR"

echo "Building ISO for $DISTRO $VERSION ($ARCH)..."

# 1. Populate rootfs from our package system (assuming UPM is compiled)
# upm install --root "$WORK/airootfs" base linux-lycheeos systemd cde-compositor cde-bar cde-launcher cde-ai ollama ibus ibus-avro grub2 calamares

# 2. Run post-install hooks in chroot
# arch-chroot "$WORK/airootfs" /bin/sh << 'CHROOT'
#   systemctl enable NetworkManager ollama cde-session
#   locale-gen
#   ln -sf /usr/share/zoneinfo/Asia/Dhaka /etc/localtime
# CHROOT

# 3. Compress rootfs
# mksquashfs "$WORK/airootfs" "$WORK/airootfs.sfs" -comp zstd -Xcompression-level 19 -noappend -no-progress

# 4. Build GRUB EFI image
# grub-mkstandalone --format=x86_64-efi --output="$WORK/efi/bootx64.efi" --modules="part_gpt fat iso9660 normal search" boot/grub/grub.cfg="$PWD/grub/grub.cfg"

# 5. Create ISO
# xorriso -as mkisofs -iso-level 3 -volid "${DISTRO}_${VERSION}_${ARCH}" -appid "${DISTRO} Linux ${VERSION}" -eltorito-boot isolinux/isolinux.bin -eltorito-catalog isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table --efi-boot efi/efiboot.img -efi-boot-part --efi-boot-image --protective-msdos-label -output "$OUTDIR/${DISTRO}-${VERSION}-${ARCH}.iso" "$WORK"

# 6. Sign and checksum
# sha256sum "$OUTDIR/"*.iso > "$OUTDIR/SHA256SUMS"
# gpg --detach-sign "$OUTDIR/SHA256SUMS"

echo "✅ ISO build pipeline ready. Uncomment commands once rootfs packages are available."
