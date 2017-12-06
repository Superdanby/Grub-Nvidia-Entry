# https://github.com/Superdanby/Grub-Nvidia-Entry

Curnel=`uname -r`
if [[ `sudo sed -n '/^menuentry/,/}/p;' /boot/efi/EFI/fedora/grub.cfg | sed '/}/q' | grep $Curnel` == '' ]];then
    printf "You are not on the latest kernel!\n"
    printf "Do you wish to proceed?\n"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) break;;
            No ) exit;;
        esac
    done
fi

printf "Configuring GRUB Menu...\n"
printf "Original boot options with Nvidia modules disabled:\n"
OldKerPara=`sudo cat /etc/default/grub | grep GRUB_CMDLINE`
if [[ `sudo cat /etc/default/grub | grep GRUB_CMDLINE | grep modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset,nvidia_uvm` == '' ]]; then
    Nline=`sudo grep -n GRUB_CMDLINE /etc/default/grub | cut -d : -f 1`
    # KernelPara="${OldKerPara::-1} modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset\""
    printf "GRUB_CMDLINE is at line $Nline.\n"
    sudo sed -i "${Nline}s/\"/\ modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset,nvidia_uvm\"/2" /etc/default/grub
else
    printf "modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset,nvidia_uvm is already in the boot options.:\n$OldKerPara\n"
fi

# Enables nouveau by default
sudo sed -i 's/\<rd.driver.blacklist=nouveau\> //g' /etc/default/grub
sudo sed -i 's/\<nvidia-drm.modeset=1\> //g' /etc/default/grub

sudo cat /etc/default/grub

printf "\nNew boot menu entry with Nvidia modules enabled:\n"

echo "\
#!/bin/sh
exec tail -n +3 \$0
# This file provides an easy way to add custom menu entries.  Simply type the
# menu entries you want to add after this comment.  Be careful not to change
# the 'exec tail' line above.
`sudo sed -n '/^menuentry/,/}/p;' /boot/efi/EFI/fedora/grub.cfg | sed '/}/q' | sed 's/modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset,nvidia_uvm//'`" | sudo tee /etc/grub.d/40_custom

if [[ `sudo cat /etc/grub.d/40_custom | grep rd.driver.blacklist=nouveau` == '' ]]; then
    sudo sed -i '/vmlinuz/s/$/ rd.driver.blacklist=nouveau/' /etc/grub.d/40_custom
fi
if [[ `sudo cat /etc/grub.d/40_custom | grep nvidia-drm.modeset=1` == '' ]]; then
    sudo sed -i '/vmlinuz/s/$/ nvidia-drm.modeset=1/' /etc/grub.d/40_custom
fi

sudo cat /etc/grub.d/40_custom

sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
