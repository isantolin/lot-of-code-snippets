#!/bin/bash
# TODO: Unificar setup de base de datos en PostGRES
# TODO: - Agregar forma de cambiar DocumentRoot
# TODO: Monitorear CUDA Toolkit compatible con cuDF y Fedora

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
  dconf write /org/gnome/desktop/datetime/automatic-timezone true

  # Repository Add
  sudo dnf config-manager --add-repo https://dl.winehq.org/wine-builds/fedora/"$OS_VERSION"/winehq.repo

  sudo echo -e "[Webmin]\nname=Webmin Distribution Neutral\n#baseurl=https://download.webmin.com/download/yum\nmirrorlist=https://download.webmin.com/download/yum/mirrorlist\nenabled=1\ngpgkey=http://www.webmin.com/jcameron-key.asc" | sudo tee /etc/yum.repos.d/webmin.repo
  sudo dnf config-manager --add-repo /etc/yum.repos.d/webmin.repo

  # Other repository and external packages install
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-"$OS_VERSION".noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$OS_VERSION".noarch.rpm https://dl.google.com/linux/direct/google-chrome-beta_current_"$ARCH".rpm https://developer.download.nvidia.com/compute/cuda/repos/fedora25/"$ARCH"/cuda-repo-fedora25-9.1.85-1."$ARCH".rpm
  sudo dnf -y install rpmfusion-free-release-tainted
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

  # Update to install repository packages
  sudo find /etc/yum.repos.d/*.repo -type f -exec sed -i 's/enabled=0/enabled=1/g' {} \;
  sudo flatpak update
  sudo dnf clean all
  sudo dnf -y update --refresh
  sudo fwupdmgr get-devices
  sudo fwupdmgr refresh --force
  sudo fwupdmgr get-updates
  sudo fwupdmgr update
    
  # Install Basic Packages
  sudo dnf -y install webmin samba-winbind httpd gcc-c++ make winehq-devel nodejs cups-pdf cups-lpd libdvdcss cabextract lzip p7zip p7zip-plugins unrar alsa-plugins-pulseaudio libcurl lpf-mscore-fonts postgresql-server postgresql-contrib gstreamer1-plugin-openh264 gstreamer1-plugins-bad-free-extras gstreamer1-plugins-bad-free-fluidsynth gstreamer1-plugins-bad-free-wildmidi gstreamer1-plugins-bad-freeworld gstreamer1-plugins-base-tools gstreamer1-plugins-entrans gstreamer1-plugins-fc gstreamer1-plugins-good-extras gstreamer1-rtsp-server gstreamer1-vaapi gstreamer1-plugins-ugly xorg-x11-drv-nvidia-390xx akmod-nvidia-390xx xorg-x11-drv-nvidia-390xx-cuda kernel-devel vdpauinfo libva-vdpau-driver libva-utils php-json NetworkManager-fortisslvpn-gnome NetworkManager-iodine-gnome NetworkManager-l2tp-gnome NetworkManager-libreswan-gnome NetworkManager-sstp-gnome NetworkManager-strongswan-gnome epson-inkjet-printer-escpr NetworkManager-ovs gstreamer1-libav php-doctrine-orm gcc-gfortran cmake cuda kernel-devel-"$KERNEL"
  
  sudo flatpak install flathub io.dbeaver.DBeaverCommunity org.telegram.desktop com.jetbrains.PyCharm-Professional -y
  
  # Xorg --> Wayland
  sudo akmods --force
  sudo sed -i '/DRIVER==/d' /usr/lib/udev/rules.d/61-gdm.rules
  sudo sed -i '/WaylandEnable=false/d' /etc/gdm/custom.conf
  
  # Performance Tweaks
  sudo grubby --update-kernel=ALL --args="processor.ignore_ppc=1 nowatchdog"
  echo -e "vm.swappiness=10\nnet.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1\nnet.ipv6.conf.tun0.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf

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

  ####
  sudo /usr/libexec/webmin/changepass.pl /etc/webmin root "$password"
  ####

else
  echo "Distro no configurada"
fi

sudo mkdir /Apache
sudo chmod +x /Apache
sudo touch /Apache/.htaccess
sudo chmod -R 777 /Apache
sudo chcon -R -t httpd_sys_content_t /Apache/
sudo systemctl restart httpd

echo "Inserte Password MySQL: "
read -r password


sudo mysql -u root -p -e "install plugin validate_password soname 'validate_password.so'; SET GLOBAL validate_password.policy=LOW; ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$password'; FLUSH PRIVILEGES;"

# Web Stuff
sudo npm install -g npm@latest
sudo npm install --global gulp grunt karma bower express-generator cordova less sass

sudo pip3 install pip wheel NeuroTools matplotlib numpy --upgrade --pre
sudo dnf install parted-devel libcurl-devel cairo-devel python-devel openssl-devel krb5-devel

sudo echo -e "python3 -m pip list --outdated --pre --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install --pre --ignore-installed -U\ndnf -y update\nflatpak update -y" | sudo tee /usr/bin/auto-upgrade-ign.sh
chmod -x /usr/bin/auto-upgrade-ign.sh
sudo echo -e '[Unit]\nDescription=Auto Upgrade (Ignacio)\nWants=network-online.target\nAfter=network.target network-online.target\n[Service]\nExecStart=sh "/usr/bin/auto-upgrade-ign.sh"\n\n[Install]\nWantedBy=multi-user.target' | sudo tee /etc/systemd/system/auto-upgrade-ign.service
sudo systemctl enable auto-upgrade-ign.service

#Autostart some applications
mkdir ~/.config/autostart
cp /usr/share/applications/google-chrome-beta.desktop ~/.config/autostart
echo -e "X-GNOME-Autostart-enabled=true" | tee -a ~/.config/autostart/google-chrome-beta.desktop

#Install GPG Keys
gpg2 --import /run/media/ignaciosantolin/KEYS/private.pgp
gpg2 --keyserver keys.openpgp.org --recv-keys ADD3C408CD66D157

#Setup Printer
sudo lpadmin -p "XP-241" -E -v dnssd://EPSON%20XP-240%20Series._pdl-datastream._tcp.local/ -m lsb/usr/Epson/epson-inkjet-printer-escpr/Epson-XP-240_Series-epson-escpr-en.ppd.gz
sudo lpadmin -d "XP-241"
