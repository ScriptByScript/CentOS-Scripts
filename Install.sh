#!/bin/bash

# ------------------------------------------------------------------------------
# Filename: Install.sh
# Last Edited: 01-16-2019    
#
# Change Log
# v1.00, 04/24/2017 - Initial
# v1.01, 05/24/2017 - Cleaned up formatting
# v1.02, 05/24/2017 - Changed versioning format, changed script name
# v1.03, 07/11/2017 - Added additional entropy source
# v1.04, 07/17/2017 - Added qcache settings for mariadb, added ksm run parameter
# v1.05, 09/22/2017 - Changed redirect page to Duckduckgo
# v1.06, 12/21/2017 - Added htop to utilities
# v1.07, 01/17/2018 - Added ccze for log color formatting
# v1.08, 03/29/2018 - Added rsync to utilities
# v1.09, 01/15/2019 - Changed out NTP with Chrony
# v1.10, 01/16/2019 - Added Percona toolkit along with added memory enhancements
# ------------------------------------------------------------------------------

pause(){
 read -n1 -rsp $'Make note of the username and password you created before you procede, then press any key to continue\n'
}

clear
echo '=================================='
echo '>> CentOS 7 Server Setup Script <<'
echo '=================================='

clear
echo '================================================'
echo '>> Step 1 of 8 - Creating Administrative User <<'
echo '================================================'
echo ''
read -p "What username would you like to use for the admin user? " ansuser
adduser $ansuser
passwd $ansuser
gpasswd -a $ansuser wheel
echo ''
echo ''
echo '=========================='
echo -e '\e[31m>> IMPORTANT STEP BELOW <<\e[0m'
echo '=========================='
echo ''
pause
echo '==========================================================='
echo -e '>> Step 1 of 8 - Creating Administrative User - \e[32mComplete\e[0m <<'
echo '==========================================================='
sleep 5

clear
echo '============================================='
echo '>> Step 2 of 8 - Disabling Root SSH Access <<'
echo '============================================='
echo 'PermitRootLogin no' >> /etc/ssh/sshd_config
systemctl reload ssh
echo '========================================'
echo -e '>> Step 2 of 8 - Configuring Firewall - \e[32mComplete\e[0m <<'
echo '========================================'

clear
echo '========================================'
echo '>> Step 3 of 8 - Configuring Firewall <<'
echo '========================================'
sleep 2
yum install firewalld -y
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload
echo '==================================================='
echo -e '>> Step 3 of 8 - Configuring Firewall - \e[32mComplete\e[0m <<'
echo '==================================================='
sleep 5

clear
echo '============================================================================='
echo '>> Step 4 of 8 - Setting Timezone To America/Chicago and Installing Chrony <<'
echo '============================================================================='
sleep 2
timedatectl set-timezone America/Chicago
yum install chrony -y
systemctl enable chronyd
systemctl start chronyd
echo '======================================================================================='
echo -e '>> Step 4 of 8 - Setting Timezone To America/Chicago and Installing Chrony - \e[32mComplete\e[0m <<'
echo '======================================================================================='
sleep 5

clear
echo '=================================================================='
echo '>> Step 5 of 8 - Installing EPEL Repository and Updating System <<'
echo '=================================================================='
sleep 2
yum install epel-release -y
yum install yum-plugin-protectbase.noarch -y
yum makecache
yum update -y
echo '============================================================================='
echo -e '>> Step 5 of 8 - Installing EPEL Repository and Updating System - \e[32mComplete\e[0m <<'
echo '============================================================================='
sleep 5

clear
echo '==================================================='
echo '>> Step 6 of 8 - Installing Additional Utilities <<'
echo '==================================================='
sleep 2
yum install open-vm-tools -y
yum install nano ncdu wget unzip haveged htop ccze rsync -y
systemctl enable haveged
systemctl start haveged
echo '=============================================================='
echo -e '>> Step 6 of 8 - Installing Additional Utilities - \e[32mComplete\e[0m <<'
echo '=============================================================='
sleep 5

clear
echo '============================================='
echo '>> Step 7 of 8 - Configure System Hostname <<'
echo '============================================='
echo ''
read -p "What hostname would you like to use for this server (without the domain)? " anshost
echo ''
read -p "What is your domain name for this server? " ansdom
hostnamectl set-hostname $anshost
ip=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
echo $ip $anshost.$ansdom $anshost >> /etc/hosts
cat /etc/hosts
echo '========================================================'
echo -e '>> Step 7 of 8 - Configure System Hostname - \e[32mComplete\e[0m <<'
echo '========================================================'
sleep 5

clear
echo '==================================='
echo '>> Step 8 of 8 - Disable SELINUX <<'
echo '==================================='
sed -i --follow-symlinks 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux && cat /etc/sysconfig/selinux
echo '=============================================='
echo -e '>> Step 8 of 8 - Disable SELINUX - \e[32mComplete\e[0m <<'
echo '=============================================='
sleep 5

clear
echo '========================================='
echo '>> Optional Step 1 of 1 - Install LAMP <<'
echo '========================================='
while true
do
  read -p "Would you like to install LAMP? (Y/N) " ansopt1

  case $ansopt1 in
   [yY]* ) yum install httpd -y
		   sudo yum install http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm -y
		   yum install percona-toolkit -y
		   systemctl start httpd.service
           systemctl enable httpd.service
           yum install mariadb-server mariadb mytop -y
		   sed -i '/Systemd/a query_cache_type = 1' /etc/my.cnf
		   sed -i '/Systemd/a query_cache_limit = 256K' /etc/my.cnf
		   sed -i '/Systemd/a query_cache_min_res_unit = 2k' /etc/my.cnf
		   sed -i '/Systemd/a query_cache_size = 80M' /etc/my.cnf
		   sed -i '/Systemd/a malloc-lib=/usr/lib64/libjemalloc.so.1' /etc/my.cnf
		   systemctl start mariadb
           mysql_secure_installation
           systemctl enable mariadb.service
           yum install php php-mysql php-fpm php-cli php-common php-devel php-pear php-gd php-mbstring php-xml php-ldap -y
		   sed -i '5s$SetHandler application/x-httpd-php$SetHandler proxy:fcgi://127.0.0.1:9000$g' /etc/httpd/conf.d/php.conf
		   sed -i 's$;date.timezone =$date.timezone = America/Chicago$g' /etc/php.ini
		   systemctl start php-fpm.service
		   systemctl enable php-fpm.service
		   echo '<?php phpinfo(); ?>' >> /var/www/html/info.php
		   echo '<?php header("Location: http://www.duckduckgo.com");' >> /var/www/html/index.php
		   echo 'exit; ?>' >> /var/www/html/index.php
		   chown apache:apache -R /var/www/html/
		   echo '' >> /etc/httpd/conf/httpd.conf
		   echo '# Configure MPM Prefork' >> /etc/httpd/conf/httpd.conf 
		   echo 'KeepAlive Off' >> /etc/httpd/conf/httpd.conf
		   echo '<IfModule prefork.c>' >> /etc/httpd/conf/httpd.conf
		   echo '   StartServers        5' >> /etc/httpd/conf/httpd.conf
		   echo '   MinSpareServers     5' >> /etc/httpd/conf/httpd.conf
		   echo '   MaxSpareServers     10' >> /etc/httpd/conf/httpd.conf
		   echo '   MaxClients          150' >> /etc/httpd/conf/httpd.conf
		   echo '   MaxRequestsPerChild 3000' >> /etc/httpd/conf/httpd.conf
		   echo '</IfModule>' >> /etc/httpd/conf/httpd.conf
		   systemctl restart httpd.service
		   break;;

   [nN]* ) break;;

   * )     echo "Please enter Y or N";;
esac
done
while true
do 
  case $ansopt1 in
   [yY]* ) echo '===================================================='
           echo -e '>> Optional Step 1 of 1 - Install LAMP - \e[32mComplete\e[0m <<'
           echo '===================================================='
		   break;;

   [nN]* ) echo '===================================================='
           echo -e '>> Optional Step 1 of 1 - Install LAMP - \e[31mDeclined\e[0m <<'
           echo '===================================================='
           break;;
esac
done
sleep 5

clear
echo '===================================='
echo '>> All Operations Have Completed! <<'
echo '===================================='
echo ''
echo '>> Summary of Script Process <<'
echo 'Step 1 - Created administrative user'
echo 'Step 2 - Disabled SSH root access'
echo 'Step 3 - Configured firewall'
echo 'Step 4 - Set timezone and Chrony'
echo 'Step 5 - Installed EPEL repository'
echo 'Step 6 - Installed additional utilities'
echo 'Step 7 - Configured system hostname'
echo 'Step 8 - Disabled SELINUX'

while true
do 
  case $ansopt1 in
   [yY]* ) echo 'Optional Step 1 - Installed LAMP and configured services'
		   break;;

   [nN]* ) echo 'Optional Step 1 - Declined the installation of LAMP'
           break;;
esac
done

echo ''
echo ''
echo -e '\e[31mRebooting System - you will lose connection to server\e[0m'
echo ''

sleep 1
reboot
