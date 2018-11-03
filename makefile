.PHONY: disable enable force install run sign uninstall

run:
	./grub-nvidia-entry.sh

disable:
	sudo systemctl disable grub-nvidia-entry
	sudo systemctl disable gdm-nvidia-wayland-switch

enable: install
	sudo systemctl enable grub-nvidia-entry
	sudo systemctl enable gdm-nvidia-wayland-switch

force:
	./grub-nvidia-entry.sh -f

install:
	-sudo mv /etc/grub.d/40_custom.bak /etc/grub.d/40_custom || true
	-sudo mv /usr/lib/systemd/system/switcheroo-control.service.bak /usr/lib/systemd/system/switcheroo-control.service || true
	-sudo mv /usr/lib/udev/rules.d/61-gdm.rules.bak /usr/lib/udev/rules.d/61-gdm.rules || true
	-sudo mv /etc/gdm/custom.conf.bak /etc/gdm/custom.conf || true
	sudo cp /etc/gdm/custom.conf /etc/gdm/custom.conf.bak
	sudo cp /usr/lib/udev/rules.d/61-gdm.rules /usr/lib/udev/rules.d/61-gdm.rules.bak
	sudo sed -i '/^DRIVER=="nvidia".*gdm-disable-wayland/{s/^/#/}' /usr/lib/udev/rules.d/61-gdm.rules
	sudo udevadm control --reload-rules && sudo udevadm trigger
	sudo cp /usr/lib/systemd/system/switcheroo-control.service /usr/lib/systemd/system/switcheroo-control.service.bak
	sudo cp /etc/grub.d/40_custom /etc/grub.d/40_custom.bak
	sudo cp grub-nvidia-entry.service /etc/systemd/system
	sudo cp grub-nvidia-entry.sh /usr/bin
	sudo cp gdm-nvidia-wayland-switch.service /etc/systemd/system
	sudo cp gdm-nvidia-wayland-switch.sh /usr/bin
	sudo cp nnswitch.sh /usr/bin

sign:
	/bin/sh SignNvidia.sh

uninstall: disable
	sudo rm /usr/bin/grub-nvidia-entry.sh
	sudo rm /etc/systemd/system/grub-nvidia-entry.service
	sudo rm /usr/bin/gdm-nvidia-wayland-switch.sh
	sudo rm /etc/systemd/system/gdm-nvidia-wayland-switch.service
	sudo rm /usr/bin/nnswitch.sh
	-sudo mv /etc/grub.d/40_custom.bak /etc/grub.d/40_custom
	-sudo mv /usr/lib/systemd/system/switcheroo-control.service.bak /usr/lib/systemd/system/switcheroo-control.service
	-sudo mv /usr/lib/udev/rules.d/61-gdm.rules.bak /usr/lib/udev/rules.d/61-gdm.rules
	sudo udevadm control --reload-rules && sudo udevadm trigger
	-sudo mv /etc/gdm/custom.conf.bak /etc/gdm/custom.conf
