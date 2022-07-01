#!/usr/bin/bash

export VERSION="3.1.1"

rm -rf /tmp/mbed-os-program
git reset --hard
git clean -dxf

cd /arduino
mkdir mbed-os
cd mbed-os
git init
git remote add origin https://github.com/ARMmbed/mbed-os.git
git fetch --depth 1 origin 751d0cf98bb54287285103c3c5c48ae09fb7cb4c
git checkout FETCH_HEAD
cd /arduino/ArduinoCore-mbed

git clone https://github.com/arduino/ArduinoCore-API.git ../api/
ln -s ../../../api/api cores/arduino/api

source full.variables

echo $VERSION
echo $FLAVOUR
echo $VARIANTS
echo $FQBNS

# Remove mbed folder content
rm -rf cores/arduino/mbed/*

# Remove libraries not in $LIBRARIES list
if [ x$FLAVOUR != x ]; then

mkdir _libraries
cd libraries
for library in $LIBRARIES; do
mv $library ../_libraries
done
cd ..
rm -rf libraries
mv _libraries libraries

# Remove variants not in $VARIANTS list
mkdir _variants
cd variants
for variant in $VARIANTS; do
mv $variant ../_variants
done
cd ..
rm -rf variants
mv _variants variants

# Remove fqbns not in $FQBNS list
touch _boards.txt
# Save all menus (will not be displayed if unused)
cat boards.txt | grep "^menu\." >> _boards.txt
for board in $FQBNS; do
cat boards.txt | grep "$board\." >> _boards.txt
done
mv _boards.txt boards.txt

fi

export MBED_UPDATE=0

#Recompile mbed core, applying patches on origin/latest
set +e
./mbed-os-to-arduino -r /arduino/mbed-os -a NOPE:NOPE
sed -i 's/uint32_t id/uintptr_t id/' /tmp/mbed-os-program/mbed-os/targets/TARGET_RASPBERRYPI/TARGET_RP2040/gpio_api.c
set -e
for variant in $VARIANTS; do
./mbed-os-to-arduino -r /arduino/mbed-os $variant:$variant
done

# Remove bootloaders not in $BOOTLOADERS list
mkdir _bootloaders
cd bootloaders
for bootloaders in $BOOTLOADERS; do
mv $bootloaders ../_bootloaders
done
cd ..
rm -rf bootloaders
mv _bootloaders bootloaders

#Patch title in platform.txt
sed -i "s/Arduino Mbed OS Boards/Arduino Mbed OS ${FLAVOUR^} Boards/g" platform.txt
sed -i "s/9.9.9/$VERSION/g" platform.txt

BASE_FOLDER=`basename $PWD`

#Package! (remove .git, patches folders)
cd ../dist
echo "tar --exclude='*.git*' --exclude='*patches*' -cjhf ArduinoCore-mbed-$FLAVOUR-$VERSION.tar.bz2 -C .. $BASE_FOLDER"
tar --exclude='*.git*' --exclude='*patches*' -cjhf ArduinoCore-mbed-$FLAVOUR-$VERSION.tar.bz2 -C .. $BASE_FOLDER
if [ x$FLAVOUR == x ]; then
mv ArduinoCore-mbed-$FLAVOUR-$VERSION.tar.bz2 ArduinoCore-mbed-$VERSION.tar.bz2
echo FILENAME=ArduinoCore-mbed-$VERSION.tar.bz2 > /tmp/env
else
echo FILENAME=ArduinoCore-mbed-$FLAVOUR-$VERSION.tar.bz2 > /tmp/env
fi
cd -
