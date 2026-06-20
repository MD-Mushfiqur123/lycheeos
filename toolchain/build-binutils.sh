#!/bin/bash
set -e
source ../.env

echo "Building binutils pass 1 for all targets..."

cd $SOURCES
if [ ! -f "binutils-$BINUTILS_VER.tar.xz" ]; then
    wget https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VER.tar.xz
fi
tar -xf binutils-$BINUTILS_VER.tar.xz

for TARGET in "${TARGETS[@]}"; do
  echo "Building binutils for: $TARGET"
  mkdir -pv $SOURCES/binutils-build-$TARGET
  cd $SOURCES/binutils-build-$TARGET

  ../../sources/binutils-$BINUTILS_VER/configure \
    --prefix=$TOOLS \
    --with-sysroot=$LYCHEEOS \
    --target=$TARGET \
    --disable-nls \
    --enable-gprofng=no \
    --disable-werror \
    --enable-default-hash-style=gnu

  make -j$(nproc)
  make install
done

echo "binutils build complete!"
