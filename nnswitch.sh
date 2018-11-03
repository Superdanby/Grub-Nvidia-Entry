#!/bin/sh
# Nouveau-Nvidia Switcher
# https://github.com/Superdanby/Grub-Nvidia-Entry

# Get absolute path
SCRIPTPATH="$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )/$(basename "${BASH_SOURCE[0]}")"
# Get root privileges
[ "$UID" -eq 0 ] || exec sudo "$SCRIPTPATH" "$@"

# Switch to the proprietary drivers
if [[ $1 == 'start' ]]; then
    target=`ps aux | grep gnome-session-binary | grep -v grep | awk '{print $2}'`
    while [[ `sudo kill -0 $target 2>&1` == '' ]]; do
	    sudo kill $target
    done
    while [[ `systemctl status gdm | grep -w active` != '' ]]; do
	    sudo systemctl stop gdm
    done
    while [[ `lsmod | grep nouveau` != '' ]]; do
    	sudo modprobe -r nouveau
    done
    sudo modprobe nvidia
    sudo modprobe nvidia_modeset
    sudo modprobe nvidia_drm
    sudo systemctl restart gdm-nvidia-wayland-switch.service
    sudo systemctl start gdm
    exit 0
fi

# Switch to the open source dirvers
if [[ $1 == 'stop' ]]; then
    target=`ps aux | grep gnome-session-binary | grep -v grep | awk '{print $2}'`
    while [[ `sudo kill -0 $target 2>&1` == '' ]]; do
    	sudo kill $target
    done
    target=`ps aux | grep "gdm.*autostart" | grep -v grep | awk '{print $2}'`
    while [[ `sudo kill -0 $target 2>&1` == '' ]]; do
    	sudo kill -9 $target
    done
    while [[ `systemctl status gdm | grep -w active` != '' ]]; do
    	sudo systemctl stop gdm
    done
    while [[ `lsmod | grep nvidia_drm` != '' ]]; do
        sudo modprobe -r nvidia_drm
    done
    while [[ `lsmod | grep nvidia_modeset` != '' ]]; do
        sudo modprobe -r nvidia_modeset
    done
    while [[ `lsmod | grep nvidia` != '' ]]; do
        sudo modprobe -r nvidia
    done
    rm -f /dev/nvidiactl /dev/nvidia0 /dev/nvidia-modeset
    sudo modprobe nouveau
    sudo systemctl restart gdm-nvidia-wayland-switch.service
    sudo systemctl start gdm
    exit 0
fi

# Create an orphan process to prevent it from killing itself
if [[ `lsmod | grep nvidia` == '' ]]; then
    { nohup "$SCRIPTPATH" start >/dev/null 2>&1 & } &
else
    { nohup "$SCRIPTPATH" stop >/dev/null 2>&1 & } &
fi
