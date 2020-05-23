# References:
# https://www.tecmint.com/remove-unwanted-services-in-centos-7/
# https://haydenjames.io/strip-amazon-linux-ec2-maximize-available-ram/

# Replace yum-cron with a cron job 
sudo yum remove -y yum-cron
sudo sh -c 'echo "#!/bin/sh 
/usr/bin/yum -R 120 -e 0 -d 0 -y update yum 
/usr/bin/yum -R 10 -e 0 -d 0 -y update" > /etc/cron.daily/yum.cron'
sudo chmod +x /etc/cron.daily/yum.cron

# Replace chronyd with a cron job
sudo yum remove chrony
sudo sh -c 'echo "#!/bin/sh
/usr/sbin/ntpdate pool.ntp.org" > /etc/cron.weekly/ntpdate-sync'
sudo chmod +x /etc/cron.weekly/ntpdate-sync

# Clean up any unused packages
sudo yum autoremove
