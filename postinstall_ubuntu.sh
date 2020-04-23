#!/bin/bash
#Instalar Driver NVIDIA
wget -q https://dl.winehq.org/wine-builds/winehq.key -O- | sudo apt-key add -
sudo apt-add-repository "deb https://dl.winehq.org/wine-builds/ubuntu/ $(lsb_release -sc) main"

sudo echo "deb http://download.webmin.com/download/repository sarge contrib" | sudo tee /etc/apt/sources.list.d/webmin.list
wget -q http://www.webmin.com/jcameron-key.asc -O- | sudo apt-key add -

echo "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -

wget https://dl.google.com/linux/direct/google-chrome-beta_current_amd64.deb
sudo dpkg --install google-chrome-beta_current_amd64.deb
rm google-chrome-beta_current_amd64.deb

wget https://repo.skype.com/latest/skypeforlinux-64.deb
wget -q -O - https://repo.skype.com/data/SKYPE-GPG-KEY | sudo apt-key add -
sudo dpkg --install skypeforlinux-64.deb
rm skypeforlinux-64.deb

sudo add-apt-repository ppa:linuxuprising/java -y

sudo apt update
sudo apt -y upgrade
sudo apt -y full-upgrade

sudo echo "blacklist psmouse" | sudo tee /etc/modprobe.d/blacklist.conf
sudo depmod -ae && sudo update-initramfs -u

# TODO: Agregar Drivers EPSON de http://download.ebz.epson.net/dsc/search/01/search/?OSC=LX

sudo apt -y install --install-recommends winehq-devel
sudo apt -y install --install-recommends brasero
sudo apt -y install virtualbox-6.1
sudo apt -y install winbind apt-transport-https webmin tasksel ubuntu-restricted-extras build-essential synaptic libdvd-pkg  default-jdk default-jre libreoffice printer-driver-cups-pdf filezilla rabbitvcs-nautilus ffmpeg git oracle-java14-installer ruby-sass node-less php-codesniffer phpmd composer php-doctrine-orm gfortran cmake npm nodejs qt5-qmake curl network-manager-fortisslvpn-gnome network-manager-iodine-gnome network-manager-l2tp-gnome network-manager-openconnect-gnome network-manager-ssh-gnome network-manager-strongswan network-manager-vpnc-gnome python3-pip gstreamer1.0-nice gstreamer1.0-omx-generic gstreamer1.0-opencv gstreamer1.0-pipewire gstreamer1.0-pocketsphinx gstreamer1.0-rtsp gstreamer1.0-plugins-bad

sudo usermod -a -G vboxusers "$USER"

sudo tasksel install lamp-server
sudo mysql_secure_installation
sudo dpkg-reconfigure libdvd-pkg
sudo update-alternatives --config java
sudo apt install phpmyadmin -y

#Netbeans
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
