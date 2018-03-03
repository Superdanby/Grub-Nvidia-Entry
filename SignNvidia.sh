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

printf "Signing nvidia modules...\n"
openssl req -new -x509 -newkey rsa:2048 -keyout ~/MOK.priv -outform DER -out ~/MOK.der -nodes -days 36500 -subj "/CN=`groups | xargs -n 1 | tail -n +1 | head -n 1`/"
sudo /usr/src/kernels/$(uname -r)/scripts/sign-file sha256 ~/MOK.priv ~/MOK.der $(modinfo -n nvidia)
sudo /usr/src/kernels/$(uname -r)/scripts/sign-file sha256 ~/MOK.priv ~/MOK.der $(modinfo -n nvidia_drm)
sudo /usr/src/kernels/$(uname -r)/scripts/sign-file sha256 ~/MOK.priv ~/MOK.der $(modinfo -n nvidia_modeset)
sudo /usr/src/kernels/$(uname -r)/scripts/sign-file sha256 ~/MOK.priv ~/MOK.der $(modinfo -n nvidia_uvm)
printf "Enter the password to enroll MOK.\n"
sudo mokutil --import ~/MOK.der
printf "Please reboot to finish the process with MOK."
