#!/bin/bash
# TODO: Unificar setup de base de datos en PostGRES
# TODO: https://www.oracle.com/java/technologies/javase-downloads.html#JDK14
#- Agregar forma de cambiar DocumentRoot
#- Definir IDE para PHP
# Corregir espacios en Newline

DIST=$(awk -F= '/^NAME/{print $2}' '/etc/os-release')
BITS=$(getconf LONG_BIT)
ARCH=$(uname -m)

sudo echo "blacklist psmouse" | sudo tee /etc/modprobe.d/blacklist.conf

if [ "$DIST" == "Ubuntu" ] || [ "$DIST" == "Raspbian GNU/Linux" ]; then
  sudo depmod -ae && sudo update-initramfs -u

  if [ "$DIST" == "Raspbian GNU/Linux" ]; then
    sudo rpi-update
  else
    echo "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
    wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
    wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -

    wget https://dl.google.com/linux/direct/google-chrome-beta_current_"$ARCH".deb
    sudo dpkg --install google-chrome-beta_current_"$ARCH".deb
    rm google-chrome-beta_current_"$ARCH".deb
    sudo add-apt-repository ppa:linuxuprising/java -y
    sudo apt -y install virtualbox-6.1 oracle-java14-installer
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
  echo "fastestmirror=true
  deltarpm=true" | sudo tee -a /etc/dnf/dnf.conf
  echo -e "127.0.0.1\tlocalhost airwave7
  ::1\tlocalhost airwave7" | sudo tee /etc/hosts
  sudo hostnamectl set-hostname airwave7
  gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true

  # Repository Add
  sudo dnf config-manager --add-repo https://dl.winehq.org/wine-builds/fedora/"$(rpm -E %fedora)"/winehq.repo
  sudo dnf config-manager --add-repo https://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo

  sudo echo "[Webmin]
  name=Webmin Distribution Neutral
  #baseurl=https://download.webmin.com/download/yum
  mirrorlist=https://download.webmin.com/download/yum/mirrorlist
  enabled=1
  gpgkey=http://www.webmin.com/jcameron-key.asc" | sudo tee /etc/yum.repos.d/webmin.repo
  sudo dnf config-manager --add-repo /etc/yum.repos.d/webmin.repo

  # Other repository and external packages install
  sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm  https://go.skype.com/skypeforlinux-64.rpm https://dl.google.com/linux/direct/google-chrome-beta_current_"$(uname -m)".rpm http://linuxdownload.adobe.com/adobe-release/adobe-release-"$(uname -i)"-1.0-1.noarch.rpm https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm
  sudo dnf -y install rpmfusion-free-release-tainted

  # Update to install repository packages
  sudo find /etc/yum.repos.d/*.repo -type f -exec sed -i 's/enabled=0/enabled=1/g' {} \;
  sudo dnf -y update --refresh
  sudo dnf -y install webmin samba-winbind httpd gcc-c++ make winehq-devel nodejs php php-cli php-php-gettext php-mbstring php-mcrypt php-pgsql php-pear php-curl php-gd php-xml php-bcmath php-zip cups-pdf cups-lpd libdvdcss cabextract lzip p7zip p7zip-plugins unrar flash-plugin alsa-plugins-pulseaudio libcurl flash-player-ppapi lpf-mscore-fonts postgresql-server postgresql-contrib gstreamer1-plugin-openh264 gstreamer1-plugins-bad-free-extras gstreamer1-plugins-bad-free-fluidsynth gstreamer1-plugins-bad-free-wildmidi gstreamer1-plugins-bad-freeworld gstreamer1-plugins-base-tools gstreamer1-plugins-entrans gstreamer1-plugins-fc gstreamer1-plugins-good-extras gstreamer1-rtsp-server gstreamer1-vaapi gstreamer1-plugins-ugly xorg-x11-drv-nvidia-390xx akmod-nvidia-390xx xorg-x11-drv-nvidia-390xx-cuda kernel-devel vdpauinfo libva-vdpau-driver libva-utils php-json NetworkManager-fortisslvpn-gnome NetworkManager-iodine-gnome NetworkManager-l2tp-gnome NetworkManager-libreswan-gnome NetworkManager-sstp-gnome NetworkManager-strongswan-gnome epson-inkjet-printer-escpr gstreamer1-svt-vp9 gstreamer1-svt-av1 gstreamer1-svt-hevc NetworkManager-ovs gstreamer1-libav php-doctrine-orm gcc-gfortran cmake snapd
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
  su - postgres
  psql -c "ALTER USER postgres WITH PASSWORD '$password';"
  sudo echo -e "host\tall\tall\tall\tmd5" | sudo tee /var/lib/pgsql/data/pg_hba.conf


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

sudo mysql -u root -p -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$password';"

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

wget https://github.com/atoum/atoum/releases/download/3.4.2/atoum.phar
sudo chmod a+x atoum.phar
sudo mv atoum.phar /usr/bin/atoum

wget https://github.com/nette/tester/releases/download/v2.3.2/tester.phar
sudo chmod a+x tester.phar
sudo mv tester.phar /usr/bin/tester

wget https://github.com/phpstan/phpstan/releases/download/0.12.19/phpstan.phar
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

sudo pear install PHP_CodeSniffer

sudo npm install -g npm@latest
sudo npm install --global gulp grunt karma phonegap bower express-generator cordova less sass
sudo pip3 install pip --upgrade

# IO scheduler udev rules: https://wiki.archlinux.org/index.php/Solid_State_Drives
# Deadline on SSDs: https://wiki.debian.org/SSDOptimization#Low-Latency_IO-Scheduler
declare {ssd,hdd}_scheduler="deadline"

cat <<EOF | tee "/etc/udev/rules.d/60-io_schedulers.rules" > /dev/null 2>&1
# Set deadline scheduler for non-rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="$ssd_scheduler"
# Set deadline scheduler for rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="$hdd_scheduler"
EOF

for disk in /sys/block/sd*; do
    rot="$disk/queue/rotational"
    sched="$disk/queue/scheduler"

    if [[ $(cat "$rot") -eq 0 ]]; then
        echo "$ssd_scheduler | tee $sched > /dev/null 2>&1"
    elif [[ $(cat "$rot") -eq 1 ]]; then
        echo "$hdd_scheduler | tee $sched > /dev/null 2>&1"
    fi
done
