#!/bin/bash
# TODO: Instalacion NVIDIA
#- Refresh de Cache una vez por día
#- Java

dnf config-manager --add-repo https://dl.winehq.org/wine-builds/fedora/$(rpm -E %fedora)/winehq.repo
dnf install winehq-devel

sudo echo "[Webmin]
name=Webmin Distribution Neutral
#baseurl=https://download.webmin.com/download/yum
mirrorlist=https://download.webmin.com/download/yum/mirrorlist
enabled=1
gpgkey=http://www.webmin.com/jcameron-key.asc" | sudo tee /etc/yum.repos.d/webmin.repo

dnf config-manager --add-repo /etc/yum.repos.d/webmin.repo

sudo dnf install https://dl.google.com/linux/direct/google-chrome-beta_current_x86_64.rpm
sudo dnf install https://go.skype.com/skypeforlinux-64.rpm
sudo dnf install webmin

sudo echo "blacklist psmouse" | sudo tee /etc/modprobe.d/blacklist.conf
sudo depmod -ae && sudo dracut -f /boot/initramfs-currentimage

sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf install https://download3.ebz.epson.net/dsc/f/03/00/09/76/14/ab1eea2026fa53856550fd626f534a7dcb0e6e42/epson-inkjet-printer-escpr-1.7.2-1lsb3.2.x86_64.rpm
sudo dnf install https://download3.ebz.epson.net/dsc/f/03/00/09/76/16/7a70c5e4e0f5a9e168c6f0228818a23794bbcb48/epson-printer-utility-1.1.0-1lsb3.2.x86_64.rpm

sudo dnf -y install httpd
sudo systemctl start httpd
sudo systemctl enable httpd
sudo firewall-cmd --add-service={http,https} --permanent
sudo firewall-cmd --reload
sudo dnf -y install php php-cli php-php-gettext php-mbstring php-mcrypt php-mysqlnd php-pear php-curl php-gd php-xml php-bcmath php-zip mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo mysql_secure_installation
echo "Inserte Password MySQL: "
read password

sudo mysql -u root -p -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$password';"

sudo dnf --enablerepo=*
sudo dnf update

curl https://cs.symfony.com/download/php-cs-fixer-v2.phar -o php-cs-fixer
sudo chmod a+x php-cs-fixer
sudo mv php-cs-fixer /usr/bin/php-cs-fixer

wget https://get.symfony.com/cli/installer -O - | bash
sudo mv /home/$USER/.symfony/bin/symfony /usr/local/bin/symfony

wget https://github.com/atoum/atoum/releases/download/3.3.0/atoum.phar
sudo chmod a+x atoum.phar
sudo mv atoum.phar /usr/bin/atoum

wget https://github.com/nette/tester/releases/download/v2.2.0/tester.phar 
sudo chmod a+x tester.phar
sudo mv tester.phar /usr/bin/tester

wget https://github.com/phpstan/phpstan/releases/download/0.11.12/phpstan.phar
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

sudo npm install -g npm@latest
sudo npm install --global gulp grunt karma phonegap bower express-generator cordova
# /usr/share/X11/xorg.conf.d/*
sudo pip3 install pip --upgrade
