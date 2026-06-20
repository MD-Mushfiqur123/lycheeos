#!/bin/bash
set -e
source "$(dirname "$0")/../.env"

echo "Building musl libc for all targets..."

cd $SOURCES
if [ ! -f "musl-$MUSL_VER.tar.gz" ]; then
    wget https://musl.libc.org/releases/musl-$MUSL_VER.tar.gz
fi
tar -xf musl-$MUSL_VER.tar.gz

for TARGET in "${TARGETS[@]}"; do
  echo "Building musl for: $TARGET"
  mkdir -pv $SOURCES/musl-build-$TARGET
  cd $SOURCES/musl-build-$TARGET

  ../../sources/musl-$MUSL_VER/configure \
    --prefix=/usr \
    --syslibdir=/lib \
    --disable-static \
    CROSS_COMPILE=$TARGET- \
    CFLAGS="-O3 -pipe"

  make -j$(nproc)
  make DESTDIR=$LYCHEEOS install
done

echo "musl libc build complete!"
