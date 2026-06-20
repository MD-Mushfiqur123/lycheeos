#!/bin/bash
set -e
source ../.env

echo "Building GCC pass 1 for all targets..."

cd $SOURCES
if [ ! -f "gcc-$GCC_VER.tar.xz" ]; then
    wget https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VER/gcc-$GCC_VER.tar.xz
fi
tar -xf gcc-$GCC_VER.tar.xz

cd gcc-$GCC_VER
./contrib/download_prerequisites
cd ..

for TARGET in "${TARGETS[@]}"; do
  echo "Building GCC pass 1 for: $TARGET"
  mkdir -pv $SOURCES/gcc-build-pass1-$TARGET
  cd $SOURCES/gcc-build-pass1-$TARGET

  ../../sources/gcc-$GCC_VER/configure \
    --prefix=$TOOLS \
    --with-sysroot=$LYCHEEOS \
    --target=$TARGET \
    --with-newlib \
    --without-headers \
    --enable-default-pie \
    --enable-default-ssp \
    --disable-nls \
    --disable-shared \
    --disable-multilib \
    --disable-threads \
    --disable-libatomic \
    --disable-libgomp \
    --disable-libquadmath \
    --disable-libssp \
    --disable-libvtv \
    --disable-libstdcxx \
    --enable-languages=c,c++,lto

  make -j$(nproc) all-gcc all-target-libgcc
  make install-gcc install-target-libgcc
done

echo "GCC pass 1 build complete!"
