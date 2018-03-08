
.PHONY: disable enable force install run sign uninstall

run:
	/bin/bash grub-nvidia-entry.sh

disable:
	sudo systemctl disable grub-nvidia-entry

enable: install
	sudo systemctl enable grub-nvidia-entry

force:
	/bin/bash grub-nvidia-entry.sh -f

install:
	-sudo rm /usr/bin/grub-nvidia-entry.sh || true
	-sudo rm /etc/systemd/system/grub-nvidia-entry.service || true
	-sudo mv /etc/grub.d/40_custom.bak /etc/grub.d/40_custom || true
	-sudo mv /usr/lib/systemd/system/switcheroo-control.service.bak /usr/lib/systemd/system/switcheroo-control.service || true
	sudo mv /usr/lib/systemd/system/switcheroo-control.service /usr/lib/systemd/system/switcheroo-control.service.bak
	sudo mv /etc/grub.d/40_custom /etc/grub.d/40_custom.bak
	sudo cp grub-nvidia-entry.service /etc/systemd/system
	sudo cp grub-nvidia-entry.sh /usr/bin
	sudo chmod 775 /usr/bin/grub-nvidia-entry.sh

sign:
	/bin/bash SignNvidia.sh

uninstall: disable
	-sudo systemctl disable grub-nvidia-entry
	sudo rm /usr/bin/grub-nvidia-entry.sh
	sudo rm /etc/systemd/system/grub-nvidia-entry.service
	-sudo mv /etc/grub.d/40_custom.bak /etc/grub.d/40_custom
	-sudo mv /usr/lib/systemd/system/switcheroo-control.service.bak /usr/lib/systemd/system/switcheroo-control.service
