# Grub-Nvidia-Entry
If you installed Nvidia drivers through [Negativo17](negativo17.org) or [RPMfusion](https://rpmfusion.org/Howto/NVIDIA), the Nvidia card would always be on by default. As the dedicated GPU consumes a lot of power, it is a significant problem to those using laptops.

grub-nvidia-entry.sh makes Grub load Nouveau instead of Nvidia drivers on normal basis and creates a new entry which loads Nvidia drivers.

## Advantages
[Why is this method preferred over Bumblebee?](https://superdanby.github.io/Blog/dealing-with-nvidia-optimus.html)

## Prerequisites
*   UEFI
*   Nvidia drivers from [Negativo17](negativo17.org) or [RPMfusion](https://rpmfusion.org/Howto/NVIDIA)

## Supported Operating Systems
*   Fedora 26 ~ 28

## Instructions
To make the script do everything automatically, run `make enable`. And to completely remove everything, run `make uninstall`.

## Usage
*   `make` or `make run`: Runs `grub-nvidia-entry.sh`.
*   `make force`: Runs `grub-nvidia-entry.sh` without checking Linux kernel version and the presence of Nvidia modules.
*   `make enable`: Registers `grub-nvidia-entry` as a service and enables it. It will update automatically on the next boot of a kernel update. However, you'll have to reboot again to see the changes.
*   `make disable`: Disables `grub-nvidia-entry`.
*   `make install`: Registers `grub-nvidia-entry` as a service.
*   `make uninstall`: Disables `grub-nvidia-entry` and deregisters it.
*   `make sign`: Signs Nvidia modules for Secure Boot with `SignNvidia.sh`.

## Caution
The script overwrites `/usr/lib/systemd/system/switcheroo-control.service` and `/etc/grub.d/40_custom`.

## Issues
*   There's an [upstream bug](https://bugzilla.redhat.com/show_bug.cgi?id=1476366) that [prevents Gnome from detecting dedicated GPU](https://github.com/Superdanby/Grub-Nvidia-Entry/issues/2) when Secure Boot is on. `DRI_PRIME=1` works fine though. A workaround is to disable Secure Boot for now.
