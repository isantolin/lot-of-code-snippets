#!/bin/bash
# TODO: - Agregar forma de cambiar DocumentRoot
# TODO - Rasp: https://github.com/shivasiddharth/Stremio-RaspberryPi

DIST=$(awk -F= '/^NAME/{print $2}' '/etc/os-release')
BITS=$(getconf LONG_BIT)
ARCH=$(uname -m)

KERNEL=$(uname -r)
COMPUTER_ID='airwave7'

#Disabled Touchpad on X11
sudo echo -e 'Section "InputClass"\n\tIdentifier "ETPS/2 Elantech Touchpad"\n\tMatchProduct "ETPS/2 Elantech Touchpad"\n\tMatchIsTouchpad "on"\n\tMatchOS "Linux"\n\tMatchDevicePath "/dev/input/event*"\n\tOption "Ignore" "on"\nEndSection\n' | sudo tee /etc/X11/xorg.conf.d/synaptics.conf
#Disabled Touchpad on Wayland
sudo echo -e 'ATTRS{name}=="ETPS/2 Elantech Touchpad", ENV{ID_INPUT}="", ENV{ID_INPUT_MOUSE}="", ENV{ID_INPUT_POINTINGSTICK}=""' | sudo tee /usr/lib/udev/rules.d/75-elan-touch.rules

if [ "$DIST" == "Ubuntu" ] || [ "$DIST" == "Raspbian GNU/Linux" ]; then
  OS_VERSION=$(lsb_release -sc)

  if [ "$DIST" == "Raspbian GNU/Linux" ]; then
    sudo rpi-update
  else
    wget https://dl.google.com/linux/direct/google-chrome-beta_current_"$ARCH".deb
    sudo dpkg --install google-chrome-beta_current_"$ARCH".deb
    rm google-chrome-beta_current_"$ARCH".deb
  fi

  wget -q https://dl.winehq.org/wine-builds/winehq.key -O- | sudo apt-key add -
  sudo apt-add-repository "deb https://dl.winehq.org/wine-builds/ubuntu/ $OS_VERSION main"

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

elif [ "$DIST" == "Fedora" ]; then
  OS_VERSION=$(rpm -E %fedora)
  echo -e "fastestmirror=true\ndeltarpm=true\nmax_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf
  echo -e "127.0.0.1\tlocalhost $COMPUTER_ID\n::1\tlocalhost $COMPUTER_ID" | sudo tee /etc/hosts
  sudo hostnamectl set-hostname $COMPUTER_ID
  gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true
  gsettings set org.gnome.desktop.datetime automatic-timezone true
  gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'br')]"

  # Repository Add
  sudo dnf config-manager --add-repo https://dl.winehq.org/wine-builds/fedora/"$OS_VERSION"/winehq.repo

  sudo echo -e "[Webmin]\nname=Webmin Distribution Neutral\n#baseurl=https://download.webmin.com/download/yum\nmirrorlist=https://download.webmin.com/download/yum/mirrorlist\nenabled=1\ngpgkey=http://www.webmin.com/jcameron-key.asc" | sudo tee /etc/yum.repos.d/webmin.repo
  sudo dnf config-manager --add-repo /etc/yum.repos.d/webmin.repo

  # Other repository and external packages install
  sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-"$OS_VERSION".noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$OS_VERSION".noarch.rpm https://dl.google.com/linux/direct/google-chrome-beta_current_"$ARCH".rpm https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
  
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
  sudo dnf -y install webmin samba-winbind httpd gcc-c++ make winehq-devel nodejs cups-pdf cups-lpd cabextract lzip p7zip p7zip-plugins unrar alsa-plugins-pulseaudio libcurl postgresql-server postgresql-contrib gstreamer1-plugin-openh264 gstreamer1-plugins-bad-free-extras gstreamer1-plugins-bad-free-fluidsynth gstreamer1-plugins-bad-free-wildmidi gstreamer1-plugins-bad-freeworld gstreamer1-plugins-base-tools gstreamer1-plugins-entrans gstreamer1-plugins-fc gstreamer1-plugins-good-extras gstreamer1-rtsp-server gstreamer1-vaapi gstreamer1-plugins-ugly NetworkManager-fortisslvpn-gnome NetworkManager-iodine-gnome NetworkManager-l2tp-gnome NetworkManager-libreswan-gnome NetworkManager-sstp-gnome NetworkManager-strongswan-gnome epson-inkjet-printer-escpr2 NetworkManager-ovs gstreamer1-libav gcc-gfortran cmake kernel-devel-"$KERNEL" fedora-workstation-repositories perl-App-cpanminus seabios swtpm-tools code mkfontscale xset xorg-x11-drv-nvidia-390xx akmod-nvidia-390xx xorg-x11-drv-nvidia-390xx-cuda vulkan vdpauinfo libva-vdpau-driver libva-utils
  sudo dnf -y install python-devel cairo-devel gobject-introspection-devel cairo-gobject-devel libcurl-devel krb5-devel
  sudo flatpak install flathub io.dbeaver.DBeaverCommunity org.telegram.desktop -y
  
  # TPM for QEMU + Windows 11
  mkdir /tmp/myvtpm
  swtpm_setup --tpm2 --tpmstate /tmp/myvtpm --create-ek-cert --create-platform-cert
  sudo chmod 777 -R /var/lib/swtpm-localca/
  sudo cat /sys/firmware/acpi/tables/SLIC > /usr/share/seabios/slic.bin
  sudo cat /sys/firmware/acpi/tables/MSDM > /usr/share/seabios/msdm.bin
  restorecon -R -v /usr/share/seabios/

  # NVIDIA Related commands
  sudo cp /usr/share/X11/xorg.conf.d/nvidia.conf /etc/X11/xorg.conf.d/nvidia.conf
  
  # Performance Tweaks
  sudo grubby --update-kernel=ALL --args="processor.ignore_ppc=1 nowatchdog"
  sudo grubby --update-kernel=ALL --args='nvidia-drm.modeset=1'
  sudo grubby --update-kernel=ALL --args='video=vesafb:mtrr:3'


  # Password Prompt
  echo "Inserte Password PostgreSQL: "
  read -r password

  # Lamp Configuration
  sudo systemctl enable postgresql
  sudo postgresql-setup --initdb --unit postgresql
  sudo systemctl start postgresql
  sudo firewall-cmd --add-service={http,https,postgresql} --permanent
  sudo firewall-cmd --reload
  sudo echo -e "host\tall\tall\tall\tmd5\nlocal\tall\tall\ttrust" | sudo tee /var/lib/pgsql/data/pg_hba.conf
  sudo service postgresql restart
  su - postgres
  psql -c "ALTER USER postgres WITH PASSWORD '$password';"

  sudo /usr/libexec/webmin/changepass.pl /etc/webmin root "$password"

else
  echo "Distro no configurada"
fi

sudo mkdir /Apache
sudo chmod +x /Apache
sudo touch /Apache/.htaccess
sudo chmod -R 777 /Apache
sudo chcon -R -t httpd_sys_content_t /Apache/
sudo systemctl restart httpd

# Web Stuff
sudo npm install -g npm@latest cordova
sudo pip3 install pip wheel --upgrade --pre

# Perl Upgrade
sudo cpanm App::cpanoutdated

sudo echo "pip --disable-pip-version-check list --outdated --pre --format=json | python -c \"import json, sys; print('\n'.join([x['name'] for x in json.load(sys.stdin)]))\" | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install --upgrade --pre --ignore-installed -U" | sudo tee /usr/bin/auto-upgrade-ign.sh
sudo echo -e "dnf -y update\nflatpak update -y\ncpan-outdated -p | cpanm\nfwupdmgr get-devices\nfwupdmgr refresh --force\nfwupdmgr get-updates\nfwupdmgr update" >> /usr/bin/auto-upgrade-ign.sh
chmod -x /usr/bin/auto-upgrade-ign.sh
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


#Setup Printer
sudo lpadmin -p "XP-241" -E -v socket://192.168.15.127 -m gutenprint.5.3://escp2-xp240/expert
sudo lpadmin -d "XP-241"

#Setup VM
wget https://raw.githubusercontent.com/isantolin/os-templates-and-setup/main/qemu-win11.xml
sudo virsh create qemu-win11.xml
