#!/bin/bash
sudo echo "deb http://download.webmin.com/download/repository sarge contrib" | sudo tee /etc/apt/sources.list.d/webmin.list
wget -q http://www.webmin.com/jcameron-key.asc -O- | sudo apt-key add -

sudo apt update
sudo apt -y upgrade
sudo apt -y full-upgrade

sudo apt -y install winbind apt-transport-https webmin tasksel libavcodec-extra ttf-mscorefonts-installer unrar-free build-essential synaptic libdvd-pkg  default-jdk default-jre libreoffice printer-driver-cups-pdf filezilla rabbitvcs-nautilus ffmpeg git ruby-sass node-less php-codesniffer phpmd composer php-doctrine-orm phing phpunit gfortran cmake npm nodejs qt5-qmake curl network-manager-fortisslvpn-gnome network-manager-iodine-gnome network-manager-l2tp-gnome network-manager-openconnect-gnome network-manager-ssh-gnome network-manager-strongswan network-manager-vpnc-gnome python3-pip gstreamer1.0-nice gstreamer1.0-libav gstreamer1.0-omx-generic gstreamer1.0-opencv gstreamer1.0-pipewire gstreamer1.0-pocketsphinx gstreamer1.0-rtsp gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly rpi-update

sudo rpi-update
sudo tasksel install lamp-server
sudo mysql_secure_installation
sudo dpkg-reconfigure libdvd-pkg
sudo update-alternatives --config java
sudo apt install phpmyadmin -y

#Netbeans
echo "Inserte Password MySQL: "
read password

sudo mysql -u root -p -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$password';"
sudo /usr/libexec/webmin/changepass.pl /etc/webmin root $password

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

wget https://github.com/nette/tester/releases/download/v2.3.0/tester.phar 
sudo chmod a+x tester.phar
sudo mv tester.phar /usr/bin/tester

wget https://github.com/phpstan/phpstan/releases/download/0.11.19/phpstan.phar
sudo chmod a+x phpstan.phar
sudo mv phpstan.phar /usr/bin/phpstan.phar

wget http://codeception.com/codecept.phar
sudo chmod +x codecept.phar
sudo mv codecept.phar /usr/bin/codecept.phar

sudo pear channel-discover pear.phpdoc.org
sudo pear install phpdoc/phpDocumentor

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
