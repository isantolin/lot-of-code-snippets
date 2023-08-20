#!/bin/bash
# TODO - Rasp: https://github.com/shivasiddharth/Stremio-RaspberryPi

source /etc/os-release
BITS=$(getconf LONG_BIT)
ARCH=$(uname -m)

KERNEL=$(uname -r)
COMPUTER_ID='airwave7'

#Disabled Touchpad on X11
sudo echo -e 'Section "InputClass"\n\tIdentifier "ETPS/2 Elantech Touchpad"\n\tMatchProduct "ETPS/2 Elantech Touchpad"\n\tMatchIsTouchpad "on"\n\tMatchOS "Linux"\n\tMatchDevicePath "/dev/input/event*"\n\tOption "Ignore" "on"\nEndSection\n' | sudo tee /etc/X11/xorg.conf.d/synaptics.conf
#Disabled Touchpad on Wayland
sudo echo -e 'ATTRS{name}=="ETPS/2 Elantech Touchpad", ENV{ID_INPUT}="", ENV{ID_INPUT_MOUSE}="", ENV{ID_INPUT_POINTINGSTICK}=""' | sudo tee /usr/lib/udev/rules.d/75-elan-touch.rules

#Add Webmin Repository
sudo curl -o setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh
sudo sh setup-repos.sh
  
if [ "$DIST" == "ubuntu" ] || [ "$DIST" == "raspbian" ]; then

  if [ "$DIST" == "raspbian" ]; then
    sudo rpi-update
  else
    wget https://dl.google.com/linux/direct/google-chrome-beta_current_"$ARCH".deb
    sudo dpkg --install google-chrome-beta_current_"$ARCH".deb
    rm google-chrome-beta_current_"$ARCH".deb
  fi

  wget -q https://dl.winehq.org/wine-builds/winehq.key -O- | sudo apt-key add -
  sudo apt-add-repository "deb https://dl.winehq.org/wine-builds/ubuntu/ $VERSION_ID main"

  sudo echo "deb http://download.webmin.com/download/repository sarge contrib" | sudo tee /etc/apt/sources.list.d/webmin.list
  wget -q http://www.webmin.com/jcameron-key.asc -O- | sudo apt-key add -

  sudo apt update
  sudo apt -y upgrade
  sudo apt -y full-upgrade

  sudo apt -y install --install-recommends winehq-devel
  sudo apt -y install --install-recommends brasero
  sudo apt -y install winbind apt-transport-https webmin tasksel ubuntu-restricted-extras build-essential synaptic libdvd-pkg libreoffice printer-driver-cups-pdf filezilla rabbitvcs-nautilus ffmpeg git ruby-sass node-less gfortran cmake npm nodejs qt5-qmake curl network-manager-fortisslvpn-gnome network-manager-iodine-gnome network-manager-l2tp-gnome network-manager-openconnect-gnome network-manager-ssh-gnome network-manager-strongswan network-manager-vpnc-gnome python3-pip gstreamer1.0-nice gstreamer1.0-omx-generic gstreamer1.0-opencv gstreamer1.0-pipewire gstreamer1.0-pocketsphinx gstreamer1.0-rtsp gstreamer1.0-plugins-bad

  sudo tasksel install lamp-server
  sudo mysql_secure_installation
  sudo dpkg-reconfigure libdvd-pkg

elif [ "$DIST" == "fedora" ]; then
  echo -e "fastestmirror=true\ndeltarpm=true\nmax_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf
  echo -e "127.0.0.1\tlocalhost $COMPUTER_ID\n::1\tlocalhost $COMPUTER_ID" | sudo tee /etc/hosts
  sudo hostnamectl set-hostname $COMPUTER_ID
  gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true
  gsettings set org.gnome.desktop.datetime automatic-timezone true
  gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'br')]"
  gsettings set org.gnome.desktop.interface show-battery-percentage true
  
  # Other repository and external packages install
  sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-"$VERSION_ID".noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$VERSION_ID".noarch.rpm https://dl.google.com/linux/direct/google-chrome-beta_current_"$ARCH".rpm
  
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  
  sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

  sudo dnf -y install rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

  # Update to install repository packages
  sudo find /etc/yum.repos.d/*.repo -type f -exec sed -i 's/enabled=0/enabled=1/g' {} \;
  sudo flatpak update
  sudo dnf clean all
  sudo dnf -y update --refresh
    
  # Install Basic Packages
  sudo dnf -y install webmin httpd gcc-c++ make nodejs cups-pdf cups-lpd cabextract lzip p7zip p7zip-plugins unrar alsa-plugins-pulseaudio libcurl gstreamer1-plugin-openh264 gstreamer1-plugins-bad-free-extras gstreamer1-plugins-bad-free-fluidsynth gstreamer1-plugins-bad-free-wildmidi gstreamer1-plugins-bad-freeworld gstreamer1-plugins-base-tools gstreamer1-plugins-entrans gstreamer1-plugins-fc gstreamer1-plugins-good-extras gstreamer1-rtsp-server gstreamer1-vaapi gstreamer1-plugins-ugly NetworkManager-fortisslvpn-gnome NetworkManager-iodine-gnome NetworkManager-l2tp-gnome NetworkManager-libreswan-gnome NetworkManager-sstp-gnome NetworkManager-strongswan-gnome epson-inkjet-printer-escpr2 NetworkManager-ovs gstreamer1-libav gcc-gfortran cmake fedora-workstation-repositories perl-App-cpanminus seabios swtpm-tools code mkfontscale xset xorg-x11-drv-nvidia-390xx akmod-nvidia-390xx xorg-x11-drv-nvidia-390xx-cuda vulkan vdpauinfo libva-vdpau-driver libva-utils gstreamer1-plugin-reqwest gstreamer1-plugin-reqwest gstreamer1-plugins-bad-freeworld gstreamer1-plugins-bad-free-zbar gstreamer1-svt-av1 gstreamer1-svt-vp9 httpd mariadb-server php php-common php-mysqlnd php-xml php-json php-gd php-mbstring php-pecl-imagick php-opcache php-pecl-ssh2 php-tidy nvidia-vaapi-driver xset

  sudo dnf -y install https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
  
  sudo dnf -y install python-devel cairo-devel gobject-introspection-devel cairo-gobject-devel libcurl-devel krb5-devel kernel-devel-"$KERNEL" libvirt-devel
  sudo flatpak -y install flathub io.dbeaver.DBeaverCommunity
  
  # TPM for QEMU + Windows 11
  mkdir /tmp/myvtpm
  swtpm_setup --tpm2 --tpmstate /tmp/myvtpm --create-ek-cert --create-platform-cert
  sudo chmod 777 -R /var/lib/swtpm-localca/
  sudo ln -s /sys/firmware/acpi/tables/SLIC /usr/share/seabios/slic.bin
  sudo ln -s /sys/firmware/acpi/tables/MSDM /usr/share/seabios/msdm.bin
  
  sudo restorecon -R -v /usr/share/seabios/
  sudo chmod -R 777 /usr/share/seabios/*

  # NVIDIA Related commands
  sudo cp /usr/share/X11/xorg.conf.d/nvidia.conf /etc/X11/xorg.conf.d/nvidia.conf

  # Apache related
  sudo systemctl start httpd
  sudo systemctl enable httpd
  sudo systemctl enable mariadb 
  sudo systemctl start mariadb 
  sudo mkdir /Apache
  sudo chmod +x /Apache
  sudo touch /Apache/.htaccess
  sudo chmod -R 777 /Apache
  sudo chcon -R -t httpd_sys_content_t /Apache
  sudo chcon -R -t httpd_sys_rw_content_t /Apache
  sudo setsebool -P httpd_can_network_connect true
  sudo sed -i 's/\/var\/www\/html/\/Apache/' /etc/httpd/conf/httpd.conf
  sudo firewall-cmd --add-service={http,https} --permanent
  sudo systemctl reload firewalld
  sudo systemctl restart httpd
  sudo sudo mysql_secure_installation
  
  # Performance Tweaks
  sudo grubby --update-kernel=ALL --args="processor.ignore_ppc=1 nowatchdog"
  sudo grubby --update-kernel=ALL --args='nvidia-drm.modeset=1'
  sudo grubby --update-kernel=ALL --args='video=vesafb:mtrr:3'

  sudo /usr/libexec/webmin/changepass.pl /etc/webmin root "$password"

else
  echo "Distro no configurada"
fi

# virtio-fs folder
mkdir ~/SHARE

# Web Stuff
sudo npm install -g npm@latest cordova
sudo pip3 install pip wheel --upgrade --pre

# Perl Upgrade
sudo cpanm App::cpanoutdated

sudo echo "pip --disable-pip-version-check list --outdated --pre --format=json | python -c \"import json, sys; print('\n'.join([x['name'] for x in json.load(sys.stdin)]))\" | grep -v '^-e' | cut -d = -f 1  | xargs -n1 pip install --upgrade --pre --ignore-installed -U" | sudo tee /usr/bin/auto-upgrade-ign.sh
sudo echo -e "dnf -y update\nflatpak update -y\ncpan-outdated -p | cpanm\nfwupdmgr get-devices\nfwupdmgr refresh --force\nfwupdmgr get-updates\nfwupdmgr update" >> /usr/bin/auto-upgrade-ign.sh
sudo chmod -x /usr/bin/auto-upgrade-ign.sh
sudo sh /usr/bin/auto-upgrade-ign.sh
sudo echo -e '[Unit]\nDescription=Auto Upgrade (Ignacio)\nWants=network-online.target\nAfter=network.target network-online.target\n[Service]\nExecStart=sh "/usr/bin/auto-upgrade-ign.sh"\n\n[Install]\nWantedBy=multi-user.target' | sudo tee /etc/systemd/system/auto-upgrade-ign.service
sudo systemctl enable auto-upgrade-ign.service

#Autostart some applications
mkdir ~/.config/autostart
cp /usr/share/applications/google-chrome-beta.desktop ~/.config/autostart
echo -e "X-GNOME-Autostart-enabled=true" | tee -a ~/.config/autostart/google-chrome-beta.desktop

#Install GPG Keys
gpg2 --import /run/media/ignaciosantolin/KEYS/private.pgp
gpg2 --keyserver keys.openpgp.org --recv-keys ADD3C408CD66D157

mkdir ~/.ssh/
cp /run/media/ignaciosantolin/KEYS/id_rsa ~/.ssh/id_rsa
cp /run/media/ignaciosantolin/KEYS/id_rsa.pub ~/.ssh/id_rsa.pub
sudo chmod 600 ~/.ssh/id_rs*
ssh-add ~/.ssh/id_rsa

# Signed drivers for Secure Boot
sudo /usr/sbin/kmodgenca
sudo mokutil --import /etc/pki/akmods/certs/public_key.der

# Setup Printer
sudo lpadmin -p "L3250" -E -v dnssd://EPSON%20L3250%20Series._ipp._tcp.local/ -m everywhere
sudo lpadmin -d "L3250"

# Setup VM
wget https://raw.githubusercontent.com/isantolin/os-templates-and-setup/main/qemu-win11.xml
sudo virsh create qemu-win11.xml
