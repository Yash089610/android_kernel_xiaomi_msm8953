#!/bin/sh

# to run , execute in terminal "mybuild.sh <clean/noclean> <spectrum/nospectrum> <clang/linaro>

CCACHE=$(command -v ccache)

if [ "$3" = "linaro" ]; then
  TOOLCHAIN=/home/sayan7848/aarch64-linux-android/bin/aarch64-opt-linux-android-
fi

if [ "$3" = "clang" ]; then
  TOOLCHAIN=/home/sayan7848/aarch64-linux-android-4.9/bin/aarch64-linux-android-
fi

OUT=$(pwd)/out

TARGET=$OUT/arch/arm64/boot/

JOBCOUNT="-j$(grep -c ^processor /proc/cpuinfo)"

export CROSS_COMPILE="${CCACHE} ${TOOLCHAIN}"

export KBUILD_BUILD_USER=TheHungarianHorntail

export KBUILD_BUILD_HOST=Butterbeer

if [ $3 = "clang" ]; then
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
ANYKERNEL=$(pwd)/AnyKernel
BOOT=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
ROOT=$(pwd)
SUFFIX=$(date +%Y%m%d-%H%M%S)
cd $ANYKERNEL
rm -f *.zip
rm -f zImage
rm -rf ramdisk
if [ "$2" = "spectrum" ]; then
  SSUFFIX=Spectrum
  cp -r $ROOT/spectrum/* $ANYKERNEL/
fi
if [ "$2" = "nospectrum" ]; then
  SSUFFIX=NoSpectrum
  cp -r $ROOT/nospectrum/* $ANYKERNEL/
fi
cp $BOOT $ANYKERNEL
zip -r9 Horcrux-Treble-$SSUFFIX-$SUFFIX.zip *
rm -rf ramdisk anykernel.sh
cd $ROOT
echo "Flashable zip made, find at AnyKernel2"

