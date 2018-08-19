#!/bin/sh

# to run , execute in terminal "mybuild.sh <clean/noclean> <clang/linaro>

CCACHE=$(command -v ccache)

if [ "$2" = "linaro" ]; then
  TOOLCHAIN=/home/sayan7848/aarch64-linux-android/bin/aarch64-opt-linux-android-
fi

if [ "$2" = "clang" ]; then
  TOOLCHAIN=/home/sayan7848/aarch64-linux-android-4.9/bin/aarch64-linux-android-
fi

OUT=$(pwd)/out

TARGET=$OUT/arch/arm64/boot/

JOBCOUNT="-j$(grep -c ^processor /proc/cpuinfo)"

export CROSS_COMPILE="${CCACHE} ${TOOLCHAIN}"

export KBUILD_BUILD_USER=TheHungarianHorntail

export KBUILD_BUILD_HOST=Butterbeer

if [ $2 = "clang" ]; then
  export CC=/home/sayan7848/linux-x86/clang-r328903/bin/clang
  export CLANG_TRIPLE=aarch64-linux-gnu-
fi

if [ "$1" = "clean" ]; then
  echo "Cleaning up"
  make clean O=$OUT
  make mrproper O=$OUT
fi

echo "Preparing kernel config"
make O=out ARCH=arm64 mido_defconfig
status=$?
if [ $status != 0 ]; then
	echo "You don't have a valid config for your device, code $status"
	exit $status
fi

echo "Compiling Kernel"
make $JOBCOUNT O=$OUT ARCH=arm64
status=$?
if [ $status != 0 ]; then
	echo "Building interrupted, code $status"
	exit $status
fi

echo "Making Flashable Zip"
BOOT=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
ROOT=$(pwd)
SUFFIX=$(date +%Y%m%d-%H%M%S)
SRELEASE=$ROOT/spectrum
NSRELEASE=$ROOT/nospectrum
rm -f $SRELEASE/*.zip $NSRELEASE/*.zip
rm -f $SRELEASE/zImage $NSRELEASE/zImage
cp $BOOT $SRELEASE
cp $BOOT $NSRELEASE
zip -r9 $SRELEASE/Horcrux-Treble-Spectrum-$SUFFIX.zip $SRELEASE/*
zip -r9 $NSRELEASE/Horcrux-Treble-NoSpectrum-$SUFFIX.zip $NSRELEASE/*
echo "Flashable zip made"

