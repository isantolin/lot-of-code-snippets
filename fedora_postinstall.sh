#!/bin/bash
# TODO: Instalacion NVIDIA - https://acrelinux.org/ativando-o-nvidia-optimus-no-fedora/
#- Refresh de Cache una vez por día
#- Java (No funciona Validación)
#- Simplificar Logica de Java
#- Agregar Color Remark de Consola (Fedy)
#- Agregar Netbeans

# Get Arch
if [[ "$(uname -m)" = "x86_64" ]]; then
    ARCH="x64"
else
    ARCH="x86"
fi

sudo echo "blacklist psmouse" | sudo tee /etc/modprobe.d/blacklist.conf
sudo depmod -ae && sudo dracut -f /boot/initramfs-currentimage
sudo echo "fastestmirror=true" >> /etc/dnf/dnf.conf
sudo echo "deltarpm=true" >> /etc/dnf/dnf.conf

#Repository Add
dnf config-manager --add-repo https://dl.winehq.org/wine-builds/fedora/$(rpm -E %fedora)/winehq.repo

sudo echo "[Webmin]
name=Webmin Distribution Neutral
#baseurl=https://download.webmin.com/download/yum
mirrorlist=https://download.webmin.com/download/yum/mirrorlist
enabled=1
gpgkey=http://www.webmin.com/jcameron-key.asc" | sudo tee /etc/yum.repos.d/webmin.repo
dnf config-manager --add-repo /etc/yum.repos.d/webmin.repo

# Other repository and external packages install
curl -sL https://rpm.nodesource.com/setup_12.x | sudo -E bash -
sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm https://download3.ebz.epson.net/dsc/f/03/00/09/76/14/ab1eea2026fa53856550fd626f534a7dcb0e6e42/epson-inkjet-printer-escpr-1.7.2-1lsb3.2.x86_64.rpm https://download3.ebz.epson.net/dsc/f/03/00/09/76/16/7a70c5e4e0f5a9e168c6f0228818a23794bbcb48/epson-printer-utility-1.1.0-1lsb3.2.x86_64.rpm https://go.skype.com/skypeforlinux-64.rpm https://dl.google.com/linux/direct/google-chrome-beta_current_x86_64.rpm http://linuxdownload.adobe.com/adobe-release/adobe-release-$(uname -i)-1.0-1.noarch.rpm
sudo dnf -y install rpmfusion-free-release-tainted

#JDK Install
CACHEDIR="/var/cache/fedy/jdk"
mkdir -p "$CACHEDIR"
cd "$CACHEDIR"

URL=$(wget $(wget "http://www.oracle.com/technetwork/java/javase/downloads/index.html" -O - | tr ' ' '\n' | grep "/technetwork/java/javase/downloads/jdk8" | head -n 1 | cut -d\" -f 2 | sed -e 's/^/http:\/\/www.oracle.com/') -O - | grep "Linux ${ARCH}" | grep ".rpm" | cut -d\" -f 12 | grep -v demos | head -n 1)
FILE=${URL##*/}

wget --header "Cookie: oraclelicense=a" -c "$URL" -O "$FILE"

if [[ -f "$FILE" ]]; then
    dnf -y install "$FILE"
else
    exit 1
fi

mkdir -p /usr/lib/jvm /usr/lib/jvm-exports
alternatives --install /usr/bin/java java /usr/java/latest/bin/java 2000000 \
--slave /usr/lib/jvm/jre jre /usr/java/latest/jre \
--slave /usr/lib/jvm-exports/jre jre_exports /usr/java/latest/jre/lib \
--slave /usr/bin/keytool keytool /usr/java/latest/jre/bin/keytool \
--slave /usr/bin/orbd orbd /usr/java/latest/jre/bin/orbd \
--slave /usr/bin/pack200 pack200 /usr/java/latest/jre/bin/pack200 \
--slave /usr/bin/rmid rmid /usr/java/latest/jre/bin/rmid \
--slave /usr/bin/rmiregistry rmiregistry /usr/java/latest/jre/bin/rmiregistry \
--slave /usr/bin/servertool servertool /usr/java/latest/jre/bin/servertool \
--slave /usr/bin/tnameserv tnameserv /usr/java/latest/jre/bin/tnameserv \
--slave /usr/bin/unpack200 unpack200 /usr/java/latest/jre/bin/unpack200 \
--slave /usr/share/man/man1/java.1 java.1 /usr/java/latest/man/man1/java.1 \
--slave /usr/share/man/man1/keytool.1 keytool.1 /usr/java/latest/man/man1/keytool.1 \
--slave /usr/share/man/man1/orbd.1 orbd.1 /usr/java/latest/man/man1/orbd.1 \
--slave /usr/share/man/man1/pack200.1 pack200.1 /usr/java/latest/man/man1/pack200.1 \
--slave /usr/share/man/man1/rmid.1.gz rmid.1 /usr/java/latest/man/man1/rmid.1 \
--slave /usr/share/man/man1/rmiregistry.1 rmiregistry.1 /usr/java/latest/man/man1/rmiregistry.1 \
--slave /usr/share/man/man1/servertool.1 servertool.1 /usr/java/latest/man/man1/servertool.1 \
--slave /usr/share/man/man1/tnameserv.1 tnameserv.1 /usr/java/latest/man/man1/tnameserv.1 \
--slave /usr/share/man/man1/unpack200.1 unpack200.1 /usr/java/latest/man/man1/unpack200.1
alternatives --auto java
alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 2000000 \
--slave /usr/lib/jvm/java java_sdk /usr/java/latest \
--slave /usr/lib/jvm-exports/java java_sdk_exports /usr/java/latest/lib \
--slave /usr/bin/appletviewer appletviewer /usr/java/latest/bin/appletviewer \
--slave /usr/bin/apt apt /usr/java/latest/bin/apt \
--slave /usr/bin/extcheck extcheck /usr/java/latest/bin/extcheck \
--slave /usr/bin/jar jar /usr/java/latest/bin/jar \
--slave /usr/bin/jarsigner jarsigner /usr/java/latest/bin/jarsigner \
--slave /usr/bin/javadoc javadoc /usr/java/latest/bin/javadoc \
--slave /usr/bin/javah javah /usr/java/latest/bin/javah \
--slave /usr/bin/javap javap /usr/java/latest/bin/javap \
--slave /usr/bin/jconsole jconsole /usr/java/latest/bin/jconsole \
--slave /usr/bin/jdb jdb /usr/java/latest/bin/jdb \
--slave /usr/bin/jhat jhat /usr/java/latest/bin/jhat \
--slave /usr/bin/jinfo jinfo /usr/java/latest/bin/jinfo \
--slave /usr/bin/jmap jmap /usr/java/latest/bin/jmap \
--slave /usr/bin/jps jps /usr/java/latest/bin/jps \
--slave /usr/bin/jrunscript jrunscript /usr/java/latest/bin/jrunscript \
--slave /usr/bin/jsadebugd jsadebugd /usr/java/latest/bin/jsadebugd \
--slave /usr/bin/jstack jstack /usr/java/latest/bin/jstack \
--slave /usr/bin/jstat jstat /usr/java/latest/bin/jstat \
--slave /usr/bin/jstatd jstatd /usr/java/latest/bin/jstatd \
--slave /usr/bin/native2ascii native2ascii /usr/java/latest/bin/native2ascii \
--slave /usr/bin/policytool policytool /usr/java/latest/bin/policytool \
--slave /usr/bin/rmic rmic /usr/java/latest/bin/rmic \
--slave /usr/bin/schemagen schemagen /usr/java/latest/bin/schemagen \
--slave /usr/bin/serialver serialver /usr/java/latest/bin/serialver \
--slave /usr/bin/wsgen wsgen /usr/java/latest/bin/wsgen \
--slave /usr/bin/wsimport wsimport /usr/java/latest/bin/wsimport \
--slave /usr/bin/xjc xjc /usr/java/latest/bin/xjc \
--slave /usr/share/man/man1/appletviewer.1 appletviewer.1 /usr/java/latest/man/man1/appletviewer.1 \
--slave /usr/share/man/man1/apt.1 apt.1 /usr/java/latest/man/man1/apt.1 \
--slave /usr/share/man/man1/extcheck.1 extcheck.1 /usr/java/latest/man/man1/extcheck.1 \
--slave /usr/share/man/man1/jar.1 jar.1 /usr/java/latest/man/man1/jar.1 \
--slave /usr/share/man/man1/jarsigner.1 jarsigner.1 /usr/java/latest/man/man1/jarsigner.1 \
--slave /usr/share/man/man1/javac.1 javac.1 /usr/java/latest/man/man1/javac.1 \
--slave /usr/share/man/man1/javadoc.1 javadoc.1 /usr/java/latest/man/man1/javadoc.1 \
--slave /usr/share/man/man1/javah.1 javah.1 /usr/java/latest/man/man1/javah.1 \
--slave /usr/share/man/man1/javap.1 javap.1 /usr/java/latest/man/man1/javap.1 \
--slave /usr/share/man/man1/jconsole.1 jconsole.1 /usr/java/latest/man/man1/jconsole.1 \
--slave /usr/share/man/man1/jdb.1 jdb.1 /usr/java/latest/man/man1/jdb.1 \
--slave /usr/share/man/man1/jhat.1 jhat.1 /usr/java/latest/man/man1/jhat.1 \
--slave /usr/share/man/man1/jinfo.1 jinfo.1 /usr/java/latest/man/man1/jinfo.1 \
--slave /usr/share/man/man1/jmap.1 jmap.1 /usr/java/latest/man/man1/jmap.1 \
--slave /usr/share/man/man1/jps.1 jps.1 /usr/java/latest/man/man1/jps.1 \
--slave /usr/share/man/man1/jrunscript.1 jrunscript.1 /usr/java/latest/man/man1/jrunscript.1 \
--slave /usr/share/man/man1/jsadebugd.1 jsadebugd.1 /usr/java/latest/man/man1/jsadebugd.1 \
--slave /usr/share/man/man1/jstack.1 jstack.1 /usr/java/latest/man/man1/jstack.1 \
--slave /usr/share/man/man1/jstat.1 jstat.1 /usr/java/latest/man/man1/jstat.1 \
--slave /usr/share/man/man1/jstatd.1 jstatd.1 /usr/java/latest/man/man1/jstatd.1 \
--slave /usr/share/man/man1/native2ascii.1 native2ascii.1 /usr/java/latest/man/man1/native2ascii.1 \
--slave /usr/share/man/man1/policytool.1 policytool.1 /usr/java/latest/man/man1/policytool.1 \
--slave /usr/share/man/man1/rmic.1 rmic.1 /usr/java/latest/man/man1/rmic.1 \
--slave /usr/share/man/man1/schemagen.1 schemagen.1 /usr/java/latest/man/man1/schemagen.1 \
--slave /usr/share/man/man1/serialver.1 serialver.1 /usr/java/latest/man/man1/serialver.1 \
--slave /usr/share/man/man1/wsgen.1 wsgen.1 /usr/java/latest/man/man1/wsgen.1 \
--slave /usr/share/man/man1/wsimport.1 wsimport.1 /usr/java/latest/man/man1/wsimport.1 \
--slave /usr/share/man/man1/xjc.1 xjc.1 /usr/java/latest/man/man1/xjc.1
alternatives --auto javac

if [[ "$arch" = "x86" ]]; then
    alternatives --install /usr/lib/mozilla/plugins/libjavaplugin.so libjavaplugin.so /usr/java/latest/lib/i386/libnpjp2.so 2000000
    alternatives --auto libjavaplugin.so
elif [[ "$arch" = "x64" ]]; then
    alternatives --install /usr/lib64/mozilla/plugins/libjavaplugin.so libjavaplugin.so.x86_64 /usr/java/latest/lib/amd64/libnpjp2.so 2000000
    alternatives --auto libjavaplugin.so.x86_64
fi

# JRE Install
CACHEDIR="/var/cache/fedy/jre"
mkdir -p "$CACHEDIR"
cd "$CACHEDIR"

URL=$(wget $(wget "http://www.oracle.com/technetwork/java/javase/downloads/index.html" -O - | tr ' ' '\n' | grep "/technetwork/java/javase/downloads/jre8" | head -n 1 | cut -d\" -f 2 | sed -e 's/^/http:\/\/www.oracle.com/') -O - | grep "Linux ${ARCH}" | grep ".rpm" | cut -d\" -f 12 | grep -v demos | head -n 1)
FILE=${URL##*/}

wget --header "Cookie: oraclelicense=a" -c "$URL" -O "$FILE"

if [[ -f "$FILE" ]]; then
    rpm -ivh "$FILE"
else
    exit 1
fi

alternatives --install /usr/bin/java java /usr/java/latest/bin/java 2000000
alternatives --auto java

if [[ "$arch" = "x86" ]]; then
    alternatives --install /usr/lib/mozilla/plugins/libjavaplugin.so libjavaplugin.so /usr/java/latest/lib/i386/libnpjp2.so 2000000
    alternatives --auto libjavaplugin.so
elif [[ "$arch" = "x64" ]]; then
    alternatives --install /usr/lib64/mozilla/plugins/libjavaplugin.so libjavaplugin.so.x86_64 /usr/java/latest/lib/amd64/libnpjp2.so 2000000
    alternatives --auto libjavaplugin.so.x86_64
fi

# Update to install repository packages
sudo find /etc/yum.repos.d/*.repo -type f -exec sed -i 's/enabled=0/enabled=1/g' {} \;
sudo dnf -y update
sudo dnf -y install webmin samba-winbind httpd gcc-c++ make winehq-devel nodejs php php-cli php-php-gettext php-mbstring php-mcrypt php-mysqlnd php-pear php-curl php-gd php-xml php-bcmath php-zip mariadb-server cups-pdf cups-lpd libdvdcss cabextract lzip p7zip p7zip-plugins unrar flash-plugin alsa-plugins-pulseaudio libcurl flash-player-ppapi lpf-mscore-fonts mariadb mariadb-server gstreamer1-plugin-openh264 gstreamer1-plugins-bad-free-extras gstreamer1-plugins-bad-free-fluidsynth gstreamer1-plugins-bad-free-wildmidi gstreamer1-plugins-bad-freeworld gstreamer1-plugins-bad-nonfree gstreamer1-plugins-base-tools gstreamer1-plugins-entrans gstreamer1-plugins-fc gstreamer1-plugins-good-extras gstreamer1-rtsp-server gstreamer1-vaapi

# Lamp Configuration
sudo systemctl start httpd
sudo systemctl enable httpd
sudo firewall-cmd --add-service={http,https} --permanent
sudo firewall-cmd --reload
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo mysql_secure_installation
echo "Inserte Password MySQL: "
read password

sudo mysql -u root -p -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password USING '$password';"

# Web Stuff related to Netbeans
curl https://cs.symfony.com/download/php-cs-fixer-v2.phar -o php-cs-fixer
sudo chmod a+x php-cs-fixer
sudo mv php-cs-fixer /usr/bin/php-cs-fixer

wget https://get.symfony.com/cli/installer -O - | bash
mv /root/.symfony/bin/symfony /usr/local/bin/symfony

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
