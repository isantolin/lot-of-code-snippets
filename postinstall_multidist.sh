#!/bin/bash
# TODO: Unificar setup de base de datos en PostGRES
# TODO: https://www.oracle.com/java/technologies/javase-downloads.html#JDK14
# TODO: - Agregar forma de cambiar DocumentRoot
# TODO: Automatizar descarga de Netbeans
# TODO: Atoum, Tester Automatizar
# TODO: Monitorear CUDA Toolkit compatible con cuDF y Fedora

DIST=$(awk -F= '/^NAME/{print $2}' '/etc/os-release')
BITS=$(getconf LONG_BIT)
ARCH=$(uname -m)

sudo echo "blacklist psmouse" | sudo tee /etc/modprobe.d/blacklist.conf

if [ "$DIST" == "Ubuntu" ] || [ "$DIST" == "Raspbian GNU/Linux" ]; then
  sudo depmod -ae && sudo update-initramfs -u

  if [ "$DIST" == "Raspbian GNU/Linux" ]; then
    sudo rpi-update
  else
    wget https://dl.google.com/linux/direct/google-chrome-beta_current_"$ARCH".deb
    sudo dpkg --install google-chrome-beta_current_"$ARCH".deb
    rm google-chrome-beta_current_"$ARCH".deb
    sudo add-apt-repository ppa:linuxuprising/java -y
    sudo apt -y install oracle-java14-installer
  fi

  wget -q https://dl.winehq.org/wine-builds/winehq.key -O- | sudo apt-key add -
  sudo apt-add-repository "deb https://dl.winehq.org/wine-builds/ubuntu/ $(lsb_release -sc) main"

  sudo echo "deb http://download.webmin.com/download/repository sarge contrib" | sudo tee /etc/apt/sources.list.d/webmin.list
  wget -q http://www.webmin.com/jcameron-key.asc -O- | sudo apt-key add -

  wget https://repo.skype.com/latest/skypeforlinux-"$BITS".deb
  wget -q -O - https://repo.skype.com/data/SKYPE-GPG-KEY | sudo apt-key add -
  sudo dpkg --install skypeforlinux-"$BITS".deb
  rm skypeforlinux-"$BITS".deb

  sudo apt update
  sudo apt -y upgrade
  sudo apt -y full-upgrade

  sudo apt -y install --install-recommends winehq-devel
  sudo apt -y install --install-recommends brasero
  sudo apt -y install winbind apt-transport-https webmin tasksel ubuntu-restricted-extras build-essential synaptic libdvd-pkg  default-jdk default-jre libreoffice printer-driver-cups-pdf filezilla rabbitvcs-nautilus ffmpeg git ruby-sass node-less php-codesniffer phpmd composer php-doctrine-orm gfortran cmake npm nodejs qt5-qmake curl network-manager-fortisslvpn-gnome network-manager-iodine-gnome network-manager-l2tp-gnome network-manager-openconnect-gnome network-manager-ssh-gnome network-manager-strongswan network-manager-vpnc-gnome python3-pip gstreamer1.0-nice gstreamer1.0-omx-generic gstreamer1.0-opencv gstreamer1.0-pipewire gstreamer1.0-pocketsphinx gstreamer1.0-rtsp gstreamer1.0-plugins-bad

  sudo tasksel install lamp-server
  sudo mysql_secure_installation
  sudo dpkg-reconfigure libdvd-pkg
  sudo update-alternatives --config java
  sudo apt install phpmyadmin -y

elif [ "$DIST" == "Fedora" ]; then
  sudo depmod -ae && sudo dracut -f /boot/initramfs-currentimage
  echo -e "fastestmirror=true\ndeltarpm=true\nmax_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf
  echo -e "127.0.0.1\tlocalhost airwave7\n::1\tlocalhost airwave7" | sudo tee /etc/hosts
  sudo hostnamectl set-hostname airwave7
  gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true

  # Repository Add
  sudo dnf config-manager --add-repo https://dl.winehq.org/wine-builds/fedora/"$(rpm -E %fedora)"/winehq.repo

  sudo echo -e "[Webmin]\nname=Webmin Distribution Neutral\n#baseurl=https://download.webmin.com/download/yum\nmirrorlist=https://download.webmin.com/download/yum/mirrorlist\nenabled=1\ngpgkey=http://www.webmin.com/jcameron-key.asc" | sudo tee /etc/yum.repos.d/webmin.repo
  sudo dnf config-manager --add-repo /etc/yum.repos.d/webmin.repo

  # Other repository and external packages install
  sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm  https://go.skype.com/skypeforlinux-64.rpm https://dl.google.com/linux/direct/google-chrome-beta_current_"$(uname -m)".rpm http://linuxdownload.adobe.com/adobe-release/adobe-release-"$(uname -i)"-1.0-1.noarch.rpm https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm
  sudo dnf -y install rpmfusion-free-release-tainted
  
  #CUDA 9.1 Install (Not tested)
  sudo dnf -y install https://developer.download.nvidia.com/compute/cuda/repos/fedora25/x86_64/cuda-repo-fedora25-9.1.85-1.x86_64.rpm

  # Update to install repository packages
  sudo find /etc/yum.repos.d/*.repo -type f -exec sed -i 's/enabled=0/enabled=1/g' {} \;
  sudo dnf -y update --refresh
  sudo dnf -y install webmin samba-winbind httpd gcc-c++ make winehq-devel nodejs php php-cli php-php-gettext php-mbstring php-mcrypt php-pgsql php-pear php-curl php-gd php-xml php-bcmath php-zip cups-pdf cups-lpd libdvdcss cabextract lzip p7zip p7zip-plugins unrar flash-plugin alsa-plugins-pulseaudio libcurl flash-player-ppapi lpf-mscore-fonts postgresql-server postgresql-contrib gstreamer1-plugin-openh264 gstreamer1-plugins-bad-free-extras gstreamer1-plugins-bad-free-fluidsynth gstreamer1-plugins-bad-free-wildmidi gstreamer1-plugins-bad-freeworld gstreamer1-plugins-base-tools gstreamer1-plugins-entrans gstreamer1-plugins-fc gstreamer1-plugins-good-extras gstreamer1-rtsp-server gstreamer1-vaapi gstreamer1-plugins-ugly xorg-x11-drv-nvidia-390xx akmod-nvidia-390xx xorg-x11-drv-nvidia-390xx-cuda kernel-devel vdpauinfo libva-vdpau-driver libva-utils php-json NetworkManager-fortisslvpn-gnome NetworkManager-iodine-gnome NetworkManager-l2tp-gnome NetworkManager-libreswan-gnome NetworkManager-sstp-gnome NetworkManager-strongswan-gnome epson-inkjet-printer-escpr NetworkManager-ovs gstreamer1-libav php-doctrine-orm gcc-gfortran cmake snapd cuda
  # Xorg --> Wayland
  sudo dnf -y install kernel-devel-5.6.6
  sudo akmods --force
  sudo sed -i '/WaylandEnable=false/d' /etc/gdm/custom.conf
  sudo sed -i '/DRIVER==/d' /usr/lib/udev/rules.d/61-gdm.rules

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

sudo usermod -a -G vboxusers "$USER"
sudo mkdir /Apache
sudo chmod +x /Apache
sudo touch /Apache/.htaccess
sudo chmod -R 777 /Apache
sudo chcon -R -t httpd_sys_content_t /Apache/
sudo systemctl restart httpd

# Comun a todo
sudo ln -s /var/lib/snapd/snap /snap
sudo systemctl enable --now snapd.socket
# sudo snap install pycharm-community --beta --classic
sudo snap install pycharm-professional --beta  --classic

echo "Inserte Password MySQL: "
read -r password


sudo mysql -u root -p -e "install plugin validate_password soname 'validate_password.so'; SET GLOBAL validate_password.policy=LOW; ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$password'; FLUSH PRIVILEGES;"

# Web Stuff related to Netbeans
sudo curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

wget -O phpunit https://phar.phpunit.de/phpunit-9.1.3.phar
sudo mv phpunit /usr/local/bin/phpunit
sudo chmod -x /usr/local/bin/phpunit

sudo pear channel-discover pear.phing.info
sudo pear install phing/phing

curl https://cs.symfony.com/download/php-cs-fixer-v2.phar -o php-cs-fixer
sudo chmod a+x php-cs-fixer
sudo mv php-cs-fixer /usr/bin/php-cs-fixer

wget https://get.symfony.com/cli/installer -O - | bash
mv /root/.symfony/bin/symfony /usr/local/bin/symfony

wget https://github.com/phpstan/phpstan/releases/download/0.12.31/phpstan.phar
sudo chmod a+x phpstan.phar
sudo mv phpstan.phar /usr/bin/phpstan.phar

wget http://codeception.com/codecept.phar
sudo chmod +x codecept.phar
sudo mv codecept.phar /usr/bin/codecept.phar

sudo wget https://pear.phpdoc.org/channel.xml
sudo pear channel-add ./channel.xml
sudo pear install phpdocumentor
sudo rm ./channel.xml

wget https://phar.phpunit.de/phpunit-skelgen.phar
chmod +x phpunit-skelgen.phar
sudo mv phpunit-skelgen.phar /usr/local/bin/phpunit-skelgen

wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

wget https://github.com/ApiGen/ApiGen.github.io/raw/master/apigen.phar
chmod +x apigen.phar
sudo mv apigen.phar /usr/bin/apigen

sudo pear channel-update pear.php.net
sudo pear install PHP_CodeSniffer

sudo npm install -g npm@latest
sudo npm install --global gulp grunt karma bower express-generator cordova less sass
sudo pip3 install pip --upgrade --pre

sudo echo -e "python3 -m pip list --outdated --pre --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 python3 -m pip install --ignore-installed --use-feature=2020-resolver --pre\ndnf -y update" | sudo tee /usr/sbin/auto-upgrade-ign.sh
chmod -x /usr/sbin/auto-upgrade-ign.sh
sudo echo -e "[Unit]\nDescription=Auto Upgrade (Ignacio)\n[Service]\nExecStart=/usr/sbin/auto-upgrade-ign.sh\n\n[Install]\nWantedBy=multi-user.target" | sudo tee /etc/systemd/system/auto-upgrade-ign.service
sudo systemctl enable auto-upgrade-ign.service
