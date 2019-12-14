#!/bin/bash
#link https://www.solvetic.com/tutoriales/article/3812-como-instalar-configurar-nagios-centos-7/
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
yum-config-manager --enable remi-php73
yum install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo -y
ip=$(ifconfig | head -2 | grep inet | awk '{print $2}')
if [ $EUID -eq 0 ]; then
sudo yum install -y gcc glibc glibc-common gd gd-devel make net-snmp openssl-devel xinetd unzip httpd 
sudo useradd nagios
sudo groupadd nagcmd
sudo usermod -a -G nagcmd nagios
curl -L -O https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.3.1.tar.gz
tar xvf nagios-*.tar.gz
cd nagios-*
./configure --with-command-group=nagcmd
make all
sudo make install
sudo make install-commandmode
sudo make install-init
sudo make install-config
sudo make install-webconf
sudo usermod -G nagcmd apache
su - 
wget http://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz | pv
tar xvf nagios-plugins-*.tar.gz
cd nagios-plugins-*.
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
sudo make install
#NRPE
cd /root
wget http://downloads.sourceforge.net/project/nagios/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz | pv
tar xvf nrpe-*.tar.gz
./configure --enable-command-args --with-nagios-user=nagios --with-nagios-group=nagios --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu
make all
sudo make install
sudo make install-xinetd
sudo make install-daemon-config
#sudo nano /etc/xinetd.d/nrpe
sed -i 's/127.0.0.1/$ip/g' /etc/xinetd.d/nrpe
sudo chkconfig nagios on
sudo chkconfig httpd on
service xinetd restart
sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
sudo systemctl restart nagios.service
sudo systemctl restart httpd.service
else
read -n 1 -p "debes ser usuario root para instalar Nagios"
fi
