#!/bin/sh


CCACHE=$(command -v ccache)

#TOOLCHAIN=/home/sayan7848/aarch64-linux-android/bin/aarch64-opt-linux-android-

OUT=$(pwd)/out

TARGET=$OUT/arch/arm64/boot/

JOBCOUNT="-j$(grep -c ^processor /proc/cpuinfo)"

#export CROSS_COMPILE="${CCACHE} ${TOOLCHAIN}"
#
#export ARCH=arm64

export KBUILD_BUILD_USER=TheHungarianHorntail

export KBUILD_BUILD_HOST=Butterbeer

echo "Cleaning up"
make clean O=$OUT
make mrproper O=$OUT

echo "Preparing kernel config"
make O=out ARCH=arm64 mido_defconfig
#make mido_defconfig O=$OUT
status=$?
if [ $status != 0 ]; then
	echo "You don't have a valid config for your device, code $status"
	exit $status
fi

echo "Compiling Kernel"
#make $JOBCOUNT O=$OUT
make -j$(nproc --all) O=$OUT \
                      ARCH=arm64 \
                      CC="/home/sayan7848/linux-x86/clang-r328903/bin/clang" \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE="/home/sayan7848/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
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
cp $BOOT $ANYKERNEL
zip -r9 Horcrux-Treble-$SUFFIX.zip * 
cd $ROOT
echo "Flashable zip made, find at AnyKernel2"

