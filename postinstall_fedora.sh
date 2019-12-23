#!/bin/bash
#- Refresh de Cache una vez por día
#- Agregar Color Remark de Consola (Fedy)
#- Agregar forma de cambiar DocumentRoot

# System configs
sudo echo "blacklist psmouse" | sudo tee /etc/modprobe.d/blacklist.conf
sudo depmod -ae && sudo dracut -f /boot/initramfs-currentimage
sudo echo "fastestmirror=true
deltarpm=true" >> /etc/dnf/dnf.conf
sudo echo -e "127.0.0.1\tlocalhost airwave7
::1\tlocalhost airwave7" | sudo tee /etc/hosts
sudo hostnamectl set-hostname airwave7

# Netbeans; https://unix.stackexchange.com/questions/64432/extract-the-base-file-name-from-a-url-using-bash
echo "Inserte URL del ARCHIVO que aparezca en la version seleccionada de: https://www.oracle.com/technetwork/java/javase/downloads/index.html "
read jdk_download_url
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "$jdk_download_url"
sudo rpm -Uvh ${jdk_download_url##*/}
sudo rm ${jdk_download_url##*/}

sudo wget http://ftp.unicamp.br/pub/apache/netbeans/netbeans/11.2/Apache-NetBeans-11.2-bin-linux-x64.sh
sudo sh Apache-NetBeans-11.2-bin-linux-x64.sh
sudo rm Apache-NetBeans-11.2-bin-linux-x64.sh

# Repository Add
sudo dnf config-manager --add-repo https://dl.winehq.org/wine-builds/fedora/$(rpm -E %fedora)/winehq.repo
sudo dnf config-manager --add-repo https://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo

sudo echo "[Webmin]
name=Webmin Distribution Neutral
#baseurl=https://download.webmin.com/download/yum
mirrorlist=https://download.webmin.com/download/yum/mirrorlist
enabled=1
gpgkey=http://www.webmin.com/jcameron-key.asc" | sudo tee /etc/yum.repos.d/webmin.repo
sudo dnf config-manager --add-repo /etc/yum.repos.d/webmin.repo

# Other repository and external packages install
sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm  https://go.skype.com/skypeforlinux-64.rpm https://dl.google.com/linux/direct/google-chrome-beta_current_$(uname -m).rpm http://linuxdownload.adobe.com/adobe-release/adobe-release-$(uname -i)-1.0-1.noarch.rpm https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm
sudo dnf -y install rpmfusion-free-release-tainted

# Update to install repository packages
sudo find /etc/yum.repos.d/*.repo -type f -exec sed -i 's/enabled=0/enabled=1/g' {} \;
sudo dnf -y update --refresh
sudo dnf -y install webmin samba-winbind httpd gcc-c++ make winehq-devel nodejs php php-cli php-php-gettext php-mbstring php-mcrypt php-pgsql php-pear php-curl php-gd php-xml php-bcmath php-zip cups-pdf cups-lpd libdvdcss cabextract lzip p7zip p7zip-plugins unrar flash-plugin alsa-plugins-pulseaudio libcurl flash-player-ppapi lpf-mscore-fonts postgresql-server postgresql-contrib gstreamer1-plugin-openh264 gstreamer1-plugins-bad-free-extras gstreamer1-plugins-bad-free-fluidsynth gstreamer1-plugins-bad-free-wildmidi gstreamer1-plugins-bad-freeworld gstreamer1-plugins-base-tools gstreamer1-plugins-entrans gstreamer1-plugins-fc gstreamer1-plugins-good-extras gstreamer1-rtsp-server gstreamer1-vaapi gstreamer1-plugins-ugly xorg-x11-drv-nvidia-390xx akmod-nvidia-390xx xorg-x11-drv-nvidia-390xx-cuda kernel-devel vdpauinfo libva-vdpau-driver libva-utils php-json NetworkManager-fortisslvpn-gnome NetworkManager-iodine-gnome NetworkManager-l2tp-gnome NetworkManager-libreswan-gnome NetworkManager-sstp-gnome NetworkManager-strongswan-gnome epson-inkjet-printer-escpr gstreamer1-svt-vp9 gstreamer1-svt-av1 NetworkManager-ovs gstreamer1-libav php-doctrine-orm gcc-gfortran cmake

# Xorg --> Wayland
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
sudo mkdir /Apache
sudo chmod +x /Apache
sudo chmod 777 /Apache
sudo systemctl restart httpd

####
sudo /usr/libexec/webmin/changepass.pl /etc/webmin root $password
####

# Web Stuff related to Netbeans
sudo curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

wget -O phpunit https://phar.phpunit.de/phpunit-8.phar
sudo mv phpunit /usr/local/bin/phpunit
sudo chmod -x /usr/local/bin/phpunit

sudo pear channel-discover pear.phing.info
sudo pear install phing/phing

curl https://cs.symfony.com/download/php-cs-fixer-v2.phar -o php-cs-fixer
sudo chmod a+x php-cs-fixer
sudo mv php-cs-fixer /usr/bin/php-cs-fixer

wget https://get.symfony.com/cli/installer -O - | bash
mv /root/.symfony/bin/symfony /usr/local/bin/symfony

wget https://github.com/atoum/atoum/releases/download/3.3.0/atoum.phar
sudo chmod a+x atoum.phar
sudo mv atoum.phar /usr/bin/atoum

wget https://github.com/nette/tester/releases/download/v2.3.1/tester.phar 
sudo chmod a+x tester.phar
sudo mv tester.phar /usr/bin/tester

wget https://github.com/phpstan/phpstan/releases/download/0.11.19/phpstan.phar
sudo chmod a+x phpstan.phar
sudo mv phpstan.phar /usr/bin/phpstan.phar

wget http://codeception.com/codecept.phar
sudo chmod +x codecept.phar
sudo mv codecept.phar /usr/bin/codecept.phar

sudo wget https://pear.phpdoc.org/channel.xml
sudo pear channel-add ./channel.xml
sudo pear install phpdoc/phpdocumentor
sudo rm /channel.xml

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
