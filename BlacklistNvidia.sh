printf "Configuring GRUB Menu...\n"
printf "Original boot options with Nvidia modules disabled:\n"
OldKerPara=`cat /etc/default/grub | grep GRUB_CMDLINE`
if [[ `cat /etc/default/grub | grep GRUB_CMDLINE | grep modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset` == '' ]]; then
        Nline=`grep -n GRUB_CMDLINE /etc/default/grub | cut -d : -f 1`
        KernelPara="${OldKerPara::-1} modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset\""
        printf "GRUB_CMDLINE is at line $Nline.\n"
        sed -i "${Nline}s/\"/\ modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset\"/2" /etc/default/grub
else
        printf "modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset is already in the boot options.:\n$OldKerPara\n"
fi

# Enables nouveau by default
sed -i 's/\<rd.driver.blacklist=nouveau\> //g' /etc/default/grub
sed -i 's/\<nvidia-drm.modeset=1\> //g' /etc/default/grub

cat /etc/default/grub

printf "\nNew boot menu entry with Nvidia modules enabled:\n"
echo "\
#!/bin/sh
exec tail -n +3 \$0
# This file provides an easy way to add custom menu entries.  Simply type the
# menu entries you want to add after this comment.  Be careful not to change
# the 'exec tail' line above.
`sed -n '/^menuentry/,/}/p;' /boot/efi/EFI/fedora/grub.cfg | sed '/}/q' | sed 's/modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset//'`" > /etc/grub.d/40_custom

cat /etc/grub.d/40_custom

grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
