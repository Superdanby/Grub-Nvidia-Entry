# Grub-Nvidia-Entry
If you installed Nvidia drivers through [Negativo17](negativo17.org) or [RPMfusion](https://rpmfusion.org/Howto/NVIDIA), the Nvidia card would always be on by default. As the dedicated GPU consumes a lot of power, it is a significant problem to those using laptops.

BlacklistNvidia.sh makes Grub load Nouveau instead of Nvidia drivers on normal basis and creates a new entry which loads Nvidia drivers.

## Advantages
[Why is this method preferred over Bumblebee?](https://superdanby.github.io/Blog/dealing-with-nvidia-optimus.html)

## Prerequisites
*   UEFI
*   Nvidia drivers from [Negativo17](negativo17.org) or [RPMfusion](https://rpmfusion.org/Howto/NVIDIA)

## Supported Operating Systems
*   Fedora 27
*   Fedora 26

## Instructions
*   After installing Nvidia drivers, run BlacklistNvidia.sh.
*   If you'd like to use the drivers with Secure Boot on, run SignNvidia.sh.
*   Rerun BlacklistNvidia.sh after a kernel update will make the created entry use the new kernel.

## Caution
The script overwrites /usr/lib/systemd/system/switcheroo-control.service and /etc/grub.d/40_custom.

## Issues
*   There's an [upstream bug](https://bugzilla.redhat.com/show_bug.cgi?id=1476366) that [prevents Gnome from detecting dedicated GPU](https://github.com/Superdanby/Grub-Nvidia-Entry/issues/2) when Secure Boot is on. `DRI_PRIME=1` works fine though. A workaround is to disable Secure Boot for now.
