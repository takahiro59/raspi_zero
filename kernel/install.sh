#!/bin/sh
sudo make modules_install
sudo cp arch/arm/boot/dts/broadcom/*.dtb /boot/firmware/
sudo cp arch/arm/boot/dts/overlays/*.dtb* /boot/firmware/overlays/
sudo cp arch/arm/boot/zImage /boot/firmware/kernel8-dev.img
echo 'kernel=kernel8-dev.img' | sudo tee -a /boot/firmware/config.txt
