#!/bin/sh

# to run , execute in terminal mybuild.sh <clean/noclean> <clang/linaro>

if [ "$#" -ne 2 ]; then
	echo "$#"
	echo "to run , execute in terminal mybuild.sh <clean/noclean> <clang/linaro>"
	exit 1
fi

if [ "$2" = "linaro" ]; then
	TOOLCHAIN=/home/sayans7848/toolchains/bin/aarch64-linux-gnu-
fi

if [ "$2" = "clang" ]; then
	TOOLCHAIN=/home/sayans7848/aarch64-linux-android-4.9/bin/aarch64-linux-android-
fi

OUT=$(pwd)/out

TARGET=$OUT/arch/arm64/boot/

JOBCOUNT="-j$(grep -c ^processor /proc/cpuinfo)"

export KBUILD_BUILD_USER=TheHungarianHorntail

export KBUILD_BUILD_HOST=Butterbeer

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
if [ $2 = "clang" ]; then
	make $JOBCOUNT O=$OUT ARCH=arm64 CC="/home/sayans7848/linux-x86/clang-r328903/bin/clang" CLANG_TRIPLE="aarch64-linux-gnu-" CROSS_COMPILE=$TOOLCHAIN
fi
if [ $2 = "linaro" ]; then
	make $JOBCOUNT O=$OUT ARCH=arm64 CROSS_COMPILE=$TOOLCHAIN
fi
status=$?
if [ $status != 0 ]; then
	echo "Building interrupted, code $status"
	exit $status
fi

