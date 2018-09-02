#!/bin/bash

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
cd $SRELEASE
zip -r9 Horcrux-Treble-Spectrum-$SUFFIX.zip *
cd $NSRELEASE
zip -r9 Horcrux-Treble-NoSpectrum-$SUFFIX.zip *
cd $ROOT
echo "Flashable zip made"
