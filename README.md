# Grub-Nvidia-Entry
If you installed Nvidia drivers through [Negativo17](https://negativo17.org/nvidia-driver/) or [RPMfusion](https://rpmfusion.org/Howto/NVIDIA), the Nvidia card would always be on by default. As the dedicated GPU consumes a lot of power, it is a significant problem to those using laptops.

## Features
*	`grub-nvidia-entry.sh` makes Grub load Nouveau instead of Nvidia drivers on normal basis and creates a new entry which loads Nvidia drivers.
*	`nnswitch.sh` lets you switch between Nouveau and Nvidia drivers within seconds.

## Usage
*	`nnswitch.sh`: Switch to Nouveau or Nvidia proprietary dirvers. You'll be brought to the login screen right after the switch. The whole process should be around 5 seconds.

## Advantages
[Why is this method preferred over Bumblebee?](https://superdanby.github.io/Blog/dealing-with-nvidia-optimus.html)

## Prerequisites
*   UEFI
*   Nvidia proprietary drivers from [Negativo17](https://negativo17.org/nvidia-driver/) or [RPMfusion](https://rpmfusion.org/Howto/NVIDIA)

## Supported Operating Systems
*   Fedora 26 ~ 29

## Installation

### Easy Setup
*	To make the script do everything automatically, run `make enable && make`.
*	To completely remove everything, run `make uninstall`.

### All Options
*   `make` or `make run`: Runs `grub-nvidia-entry.sh`. Changes take effect on the next boot.
	1.	Current session: `make` / `make run`
	2.	Next boot: changes should take effect
*   `make force`: Same as running `make`, but without checking Linux kernel's version and the presence of Nvidia modules.
*   `make enable`: Registers `grub-nvidia-entry.service` and `gdm-nvidia-wayland-switch.service` and enables them. `grub-nvidia-entry.sh` will update all configurations on the next boot. However, you'll have to reboot again to see the changes.
	1.	Current session: `make enable` / Kernel update
	2.	Next boot: `grub-nvidia-entry.sh` executes
	3.	Second boot: changes should take effect
*   `make disable`: Disables `grub-nvidia-entry.service` and `gdm-nvidia-wayland-switch.service`.
*   `make install`: Registers `grub-nvidia-entry.service` and `gdm-nvidia-wayland-switch.service`.
*   `make uninstall`: Deregisters and uninstalls all components.
*   `make sign`: Signs Nvidia modules for Secure Boot with `SignNvidia.sh`. Note that this is **NOT** included in `make enable` and should be re-run **MANUALLY** on every kernel update.

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
Full installation overwrites `/usr/lib/systemd/system/switcheroo-control.service`, `/etc/grub.d/40_custom`, `/usr/lib/udev/rules.d/61-gdm.rules`, and `/etc/gdm/custom.conf`.

## Issues
*   There's an [upstream bug](https://bugzilla.redhat.com/show_bug.cgi?id=1476366) that [prevents Gnome from detecting dedicated GPU](https://github.com/Superdanby/Grub-Nvidia-Entry/issues/2) when Secure Boot is on. `DRI_PRIME=1` works fine though. A workaround is to disable Secure Boot for now.
*   Upstream [made a change](https://bugzilla.gnome.org/show_bug.cgi?id=796315) to disable GDM's ability to launch Wayland backend if Nvidia proprietary drivers are used. However, GDM seems to be not regaining the ability even after the drivers are unloaded[need confirmation]. A workaround is applied in the commit,  [382ddeb](https://github.com/Superdanby/Grub-Nvidia-Entry/commit/382ddeb19e92282a4a4c55091c8b0615ce294e8e).

## Todo
*	RPM package
*	Better documentation for user to check what went wrong.
*	Gnome extension

## Development Stopped

I've switched to another laptop with AMD graphics card.
