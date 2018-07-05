# Grub-Nvidia-Entry
If you installed Nvidia drivers through [Negativo17](negativo17.org) or [RPMfusion](https://rpmfusion.org/Howto/NVIDIA), the Nvidia card would always be on by default. As the dedicated GPU consumes a lot of power, it is a significant problem to those using laptops.

`grub-nvidia-entry.sh` makes Grub load Nouveau instead of Nvidia drivers on normal basis and creates a new entry which loads Nvidia drivers.

## Advantages
[Why is this method preferred over Bumblebee?](https://superdanby.github.io/Blog/dealing-with-nvidia-optimus.html)

## Prerequisites
*   UEFI
*   Nvidia drivers from [Negativo17](negativo17.org) or [RPMfusion](https://rpmfusion.org/Howto/NVIDIA)

## Supported Operating Systems
*   Fedora 26 ~ 28

## Easy Setup
To make the script do everything automatically, run `make enable && make`. And to completely remove everything, run `make uninstall`.

## Usage
*   `make` or `make run`: Runs `grub-nvidia-entry.sh`. Changes take effect on the next boot.
	1.	Current session: `make` / `make run`
	2.	Next boot: changes should take effect
*   `make force`: Same as running `make`, but without checking the Linux kernel version and the presence of Nvidia modules.
*   `make enable`: Registers `grub-nvidia-entry` as a service and enables it. It will update all configurations on the next boot of a kernel update. However, you'll have to reboot again to see the changes.
	1.	Current session: `make enable` / Kernel update
	2.	Next boot: `grub-nvidia-entry.sh` executes
	3.	Second boot: changes should take effect
*   `make disable`: Disables `grub-nvidia-entry`.
*   `make install`: Registers `grub-nvidia-entry` as a service.
*   `make uninstall`: Disables `grub-nvidia-entry` and deregisters it.
*   `make sign`: Signs Nvidia modules for Secure Boot with `SignNvidia.sh`. Note that this **NOT** included in `make enable` and should be re-run **MANUALLY** on every kernel update.

## GPU Verification
### Intel/Nouveau
iGPU: `glxgears -info | grep GL_VENDOR`
![image](https://user-images.githubusercontent.com/17717083/42094545-b2c5d6e0-7be2-11e8-96ac-c02493e5aeb9.png)
dGPU(Nouveau): `DRI_PRIME=1 glxgears -info | grep GL_VENDOR`
![image](https://user-images.githubusercontent.com/17717083/42094513-9a635e60-7be2-11e8-856d-107b64721851.png)

### Intel/Nvidia
`glxgears -info | grep GL_VENDOR`
![image](https://user-images.githubusercontent.com/17717083/42094950-d1ee623e-7be3-11e8-80c8-77f8209318ba.png)

## Caution
The script overwrites `/usr/lib/systemd/system/switcheroo-control.service` and `/etc/grub.d/40_custom`.

## Issues
*   There's an [upstream bug](https://bugzilla.redhat.com/show_bug.cgi?id=1476366) that [prevents Gnome from detecting dedicated GPU](https://github.com/Superdanby/Grub-Nvidia-Entry/issues/2) when Secure Boot is on. `DRI_PRIME=1` works fine though. A workaround is to disable Secure Boot for now.
