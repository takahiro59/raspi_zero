#!/bin/sh
sudo make modules_install
sudo cp arch/arm/boot/dts/broadcom/*.dtb /boot/firmware/
sudo cp arch/arm/boot/dts/overlays/*.dtb* /boot/firmware/overlays/
sudo cp arch/arm/boot/dts/overlays/README /boot/firmware/overlays/
sudo cp arch/arm/boot/zImage /boot/firmware/kernel.img
echo 'kernel=kernel.img' | sudo tee -a /boot/firmware/config.txt
sudo sed -i '/[Service]/a Environment="USBMUXD_DEFAULT_DEVICE_MODE=3"' /usr/lib/systemd/system/usbmuxd.service
cat <<EOF | sudo tee /etc/NetworkManager/system-connections/ethusb-ios.nmconnection
[connection]
id=ethusb-ios
type=ethernet

[ethernet]

[match]
driver=idevice_debug_ncm;

[ipv4]
method=disabled

[ipv6]
addr-gen-mode=eui64
ip6-privacy=0
method=link-local

[proxy]

EOF
sudo chmod 600 /etc/NetworkManager/system-connections/ethusb-ios.nmconnection
sudo systemctl daemon-reload
sudo systemctl enable usbmuxd
echo 'Please reboot'

