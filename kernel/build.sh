#!/bin/bash
# Lychee OS Kernel Build Script (Phase 2)
set -e
source "$(dirname "$0")/../.env"

ARCH=${1:-x86_64}
echo "Building Linux kernel $KERNEL_VER for $ARCH..."

cd $SOURCES
if [ ! -f "linux-$KERNEL_VER.tar.xz" ]; then
    wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERNEL_VER.tar.xz
fi

mkdir -pv $SOURCES/linux-build-$ARCH
tar -xf linux-$KERNEL_VER.tar.xz

cd linux-$KERNEL_VER

# Apply custom patches (if any)
# patch -p1 < ../../kernel/patches/preempt-rt.patch

# Copy our custom config
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cp "$REPO_ROOT/kernel/config/${ARCH}.config" .config

# Prepare and build
make ARCH=$ARCH olddefconfig
make ARCH=$ARCH -j$(nproc) bzImage modules

# Install modules into our sysroot
make ARCH=$ARCH INSTALL_MOD_PATH=$LYCHEEOS modules_install

# Build Unified Kernel Image (UKI) if target is x86_64
if [ "$ARCH" == "x86_64" ]; then
    echo "Building Unified Kernel Image (UKI)..."
    
    # Generate initramfs with dracut
    dracut --kver $KERNEL_VER \
           --add "crypt lvm dm base" \
           --add-drivers "virtio_blk virtio_net" \
           --compress zstd \
           --early-microcode \
           --force \
           $SOURCES/linux-build-$ARCH/initramfs-$KERNEL_VER.img

    # Assuming systemd-stub is available at /usr/lib/systemd/boot/efi/linuxx64.efi.stub
    # on the host or cross-compiled sysroot
    # Note: Ensure objcopy is using the cross-toolchain in actual build
    mkdir -pv $LYCHEEOS/boot
    objcopy \
      --add-section .osrel="/etc/os-release" --change-section-vma .osrel=0x20000 \
      --add-section .cmdline="$REPO_ROOT/kernel/config/kernel.cmdline" --change-section-vma .cmdline=0x30000 \
      --add-section .linux="arch/x86/boot/bzImage" --change-section-vma .linux=0x2000000 \
      --add-section .initrd="$SOURCES/linux-build-$ARCH/initramfs-$KERNEL_VER.img" --change-section-vma .initrd=0x3000000 \
      /usr/lib/systemd/boot/efi/linuxx64.efi.stub \
      $LYCHEEOS/boot/lycheeos-$KERNEL_VER.efi
fi

echo "Kernel build complete!"
