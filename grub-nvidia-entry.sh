#!/bin/bash
# https://github.com/Superdanby/Grub-Nvidia-Entry

Curnel=`uname -r`
if [[ $1 != '-f' && $1 != '--force' ]];then
	if [[ `sudo sed -n '/^menuentry/,/}/p;' /boot/efi/EFI/fedora/grub.cfg | sed '/}/q' | grep $Curnel` == '' ]]; then
		printf "\nYou are not on the latest kernel.\n\n" 1>&2
		exit 1
	fi

	if [[ `sudo grep $Curnel /etc/grub.d/40_custom` != '' && `sudo find /lib/modules/$Curnel -name nvidia?*` != '' ]]; then
		printf "\nThe custom menu is up to date, and the Nvidia modules are already present in the latest kernel.\n\n"
		exit 0
	fi
fi

# printf "\nTo ensure Gnome detects the dGPU, switcheroo-control.service has to be kept alive.\n\n"
Switcherooctl=/usr/lib/systemd/system/switcheroo-control.service
if [[ `grep Restart= $Switcherooctl` == '' ]]; then
    sudo sed -i '/ExecStart/s/$/\nRestart=on-success/' $Switcherooctl
fi
if [[ `grep RestartSec= $Switcherooctl` == '' ]]; then
    sudo sed -i '/Restart=/s/$/\nRestartSec=5s/' $Switcherooctl
fi
if [[ `grep Restart= $Switcherooctl` == '' || `grep RestartSec= $Switcherooctl` == '' ]]; then
	printf "\nFailed to configure $Switcherooctl\n" 1>&2
	exit 2
fi
# sudo cat $Switcherooctl

# printf "\nConfiguring GRUB Menu...\n"
Dgrub=/etc/default/grub
if [[ `grep modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset,nvidia_uvm $Dgrub` == '' ]]; then
    sudo sed -i "/GRUB_CMDLINE/s/\"/\ modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset,nvidia_uvm\"/2" $Dgrub
fi
# Enables nouveau by default
sudo sed -i 's/\<rd.driver.blacklist=nouveau\> //g' $Dgrub
sudo sed -i 's/\<modprobe.blacklist=nouveau\> //g' $Dgrub
sudo sed -i 's/\<nvidia-drm.modeset=1\> //g' $Dgrub
if [[ `grep modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset,nvidia_uvm $Dgrub` == '' || \
	`grep rd.driver.blacklist=nouveau $Dgrub` || `grep modprobe.blacklist=nouveau $Dgrub` || \
	`grep nvidia-drm.modeset=1 $Dgrub` ]]; then
	printf "\nFailed to configure $Dgrub\n" 1>&2
	exit 3
fi
# sudo cat $Dgrub

# printf "\nCreating new boot menu entry with Nvidia modules enabled...\n"
Custom=/etc/grub.d/40_custom
echo "\
#!/bin/sh
exec tail -n +3 \$0
# This file provides an easy way to add custom menu entries.  Simply type the
# menu entries you want to add after this comment.  Be careful not to change
# the 'exec tail' line above.
`sudo sed -n '/^menuentry/,/}/p;' /boot/efi/EFI/fedora/grub.cfg | sed '/}/q' | sed 's/Fedora/Fedora(Nvidia)/' | sed 's/modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset,nvidia_uvm//'`" | sudo tee $Custom > /dev/null
echo '# https://github.com/Superdanby/Grub-Nvidia-Entry' | sudo tee --append $Custom > /dev/null

if [[ `sudo grep rd.driver.blacklist=nouveau $Custom` == '' ]]; then
    sudo sed -i '/vmlinuz/s/$/ rd.driver.blacklist=nouveau/' $Custom
fi
if [[ `sudo grep modprobe.blacklist=nouveau $Custom` == '' ]]; then
    sudo sed -i '/vmlinuz/s/$/ modprobe.blacklist=nouveau/' $Custom
fi
if [[ `sudo grep nvidia-drm.modeset=1 $Custom` == '' ]]; then
    sudo sed -i '/vmlinuz/s/$/ nvidia-drm.modeset=1/' $Custom
fi
if [[ `sudo grep Fedora\(Nvidia\) $Custom` == '' || `sudo grep rd.driver.blacklist=nouveau $Custom` == '' || \
	`sudo grep modprobe.blacklist=nouveau $Custom` == '' || `sudo grep nvidia-drm.modeset=1 $Custom` == '' ]]; then
	printf "\nFailed to configure custom grub entry.\n" 1>&2
	exit 4
fi
# sudo cat $Custom
sudo chmod 744 $Custom
sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

# Runs only if the modules are unavailable.
if [[ `sudo find /lib/ -name nvidia.ko | grep $Curnel` == '' ]]; then
    Nvpath="/usr/src/`ls -r /usr/src/ | grep nvidia | sed -n '1p'`"

    # printf "\nMaking Nvidia modules...\n"
    sudo make -C $Nvpath

    # printf "\nInstalling Nvidia modules...\n"
    sudo make -C $Nvpath modules_install

    # printf "\nCleaning up...\n"
    sudo make -C $Nvpath clean
fi
if [[ `sudo find /lib/ -name nvidia.ko | grep $Curnel` == '' ]]; then
	printf "\nNvidia modules compilation failed!\n"
	exit 5
fi

printf "\nSuccess! Changes will take effect on next boot."
