#!/bin/sh
# https://github.com/Superdanby/Grub-Nvidia-Entry

Curnel=`uname -r`
if [[ $1 != '-f' && $1 != '--force' ]];then
	if [[ `sudo sed -n '/^menuentry/,/}/p;' /boot/efi/EFI/fedora/grub.cfg | sed '/}/q' | grep $Curnel` == '' ]];then
		printf "\nYou are not on the latest kernel.\n\n"
		exit
	fi

	if [[ `sudo cat /etc/grub.d/40_custom | grep $Curnel` != '' && `sudo find /lib/modules/$Curnel -name nvidia?*` != '' ]];then
		printf "\nThe custom menu is up to date, and the Nvidia modules are already present in the latest kernel.\n\n"
		exit
	fi
fi

printf "\nTo ensure Gnome detects the dGPU, switcheroo-control.service has to be kept alive.\n\n"
if [[ `sudo cat /usr/lib/systemd/system/switcheroo-control.service | grep Restart=` == '' ]]; then
    sudo sed -i '/ExecStart/s/$/\nRestart=on-success/' /usr/lib/systemd/system/switcheroo-control.service
fi
if [[ `sudo cat /usr/lib/systemd/system/switcheroo-control.service | grep RestartSec=` == '' ]]; then
    sudo sed -i '/Restart=/s/$/\nRestartSec=5s/' /usr/lib/systemd/system/switcheroo-control.service
fi

# sudo cat /usr/lib/systemd/system/switcheroo-control.service

# printf "\n----------------------\n\n"
printf "Configuring GRUB Menu...\n"
# OldKerPara=`sudo cat /etc/default/grub | grep GRUB_CMDLINE`
if [[ `sudo cat /etc/default/grub | grep GRUB_CMDLINE | grep modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset,nvidia_uvm` == '' ]]; then
    Nline=`sudo grep -n GRUB_CMDLINE /etc/default/grub | cut -d : -f 1`
    # KernelPara="${OldKerPara::-1} modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset\""
    # printf "GRUB_CMDLINE is at line $Nline.\n"
    sudo sed -i "${Nline}s/\"/\ modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset,nvidia_uvm\"/2" /etc/default/grub
# else
#     printf "modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset,nvidia_uvm is already in the boot options.:\n$OldKerPara\n"
fi

# Enables nouveau by default
sudo sed -i 's/\<rd.driver.blacklist=nouveau\> //g' /etc/default/grub
sudo sed -i 's/\<modprobe.blacklist=nouveau\> //g' /etc/default/grub
sudo sed -i 's/\<nvidia-drm.modeset=1\> //g' /etc/default/grub

# sudo cat /etc/default/grub

printf "\nCreating new boot menu entry with Nvidia modules enabled...\n"

echo "\
#!/bin/sh
exec tail -n +3 \$0
# This file provides an easy way to add custom menu entries.  Simply type the
# menu entries you want to add after this comment.  Be careful not to change
# the 'exec tail' line above.
`sudo sed -n '/^menuentry/,/}/p;' /boot/efi/EFI/fedora/grub.cfg | sed '/}/q' | sed 's/modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset,nvidia_uvm//'`" | sudo tee /etc/grub.d/40_custom
echo '# https://github.com/Superdanby/Grub-Nvidia-Entry' | sudo tee --append /etc/grub.d/40_custom

if [[ `sudo cat /etc/grub.d/40_custom | grep rd.driver.blacklist=nouveau` == '' ]]; then
    sudo sed -i '/vmlinuz/s/$/ rd.driver.blacklist=nouveau/' /etc/grub.d/40_custom
fi
if [[ `sudo cat /etc/grub.d/40_custom | grep modprobe.blacklist=nouveau` == '' ]]; then
    sudo sed -i '/vmlinuz/s/$/ modprobe.blacklist=nouveau/' /etc/grub.d/40_custom
fi
if [[ `sudo cat /etc/grub.d/40_custom | grep nvidia-drm.modeset=1` == '' ]]; then
    sudo sed -i '/vmlinuz/s/$/ nvidia-drm.modeset=1/' /etc/grub.d/40_custom
fi

# sudo cat /etc/grub.d/40_custom

sudo chmod 744 /etc/grub.d/40_custom
sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

# Runs only if the modules are unavailable.
if [[ `sudo find /lib/ -name nvidia.ko | grep $Curnel` == '' ]]; then
    Nvpath="/usr/src/`ls -r /usr/src/ | grep nvidia | sed -n '1p'`"

    printf "\nMaking Nvidia modules...\n"
    sudo make -C $Nvpath

    printf "\nInstalling Nvidia modules...\n"
    sudo make -C $Nvpath modules_install

    printf "\nCleaning up...\n"
    sudo make -C $Nvpath clean
fi

printf "\nSuccess! Changes will take effect on next boot."
