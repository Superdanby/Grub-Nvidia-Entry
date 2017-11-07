# Grub-Nvidia-Entry
If you installed Nvidia drivers through negativo17.org or RPMfusion, the Nvidia card would always be on by default. As the dedicated GPU consumes a lot of power, it is a significant problem to those using laptops.

BlacklistNvidia.sh makes Grub load Nouveau instead of Nvidia drivers on normal basis and creates a new entry which loads Nvidia drivers.

[Why this method is preferred over Bumblebee?](https://superdanby.github.io/Blog/dealing-with-nvidia-optimus.html)

## Prerequisites
* UEFI
* Nvidia driver

## Supported Operating Systems
* Fedora 27
* Fedora 26

## Instructions
* After installing Nvidia drivers, run BlacklistNvidia.sh with root privileges.
* Rerun the script after a kernel update will make the created entry use the new kernel.

## Caution
The script overwrites /etc/grub.d/40_custom.
