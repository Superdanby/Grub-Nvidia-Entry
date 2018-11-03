#!/bin/sh
# https://github.com/Superdanby/Grub-Nvidia-Entry

if [[ `lsmod | grep nvidia` != '' ]]; then
	sudo sed -i 's/^#WaylandEnable=false/WaylandEnable=false/' /etc/gdm/custom.conf
	if [[ `sed -n '/^\[daemon\]/,/^\[security\]/{/^WaylandEnable=false/p}' /etc/gdm/custom.conf` == '' ]]; then
		printf "\nFailed to set WaylandEnable=false in \/etc\/gdm\/custom.conf.\n\n" 1>&2
		exit 1
	fi
else
	sudo sed -i 's/^WaylandEnable=false/#WaylandEnable=false/' /etc/gdm/custom.conf
	if [[ `sed -n '/^\[daemon\]/,/^\[security\]/{/^#WaylandEnable=false/p}' /etc/gdm/custom.conf` == '' ]]; then
		printf "\nFailed to unset WaylandEnable=false in \/etc\/gdm\/custom.conf.\n\n" 1>&2
		exit 1
	fi
fi
