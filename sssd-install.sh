#!/bin/bash

SSSDCONF=/home/mkijowski/sssd.conf

##check if root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root, exiting."
   exit 1
fi

# Must be in git directory
if [ ! -f .sssd-install.sh ]; then
   echo "This script must be run from the cloned git repo directory.
   cd to this directory and execute again."
   exit 1
fi

#fix /etc/skel
mkdir /etc/skel/.ssh
chmod 700 /etc/skel/.ssh
touch /etc/skel/.ssh/authorized_keys
echo "
if [ ! -f /home/$USER/.ssh/id_rsa ]; then
    ssh-keygen -q -t rsa -f /home/$USER/.ssh/id_rsa -N ""
    cat /home/$USER/.ssh/id_rsa.pub >> /home/$USER/.ssh/authorized_keys
fi
" >> /etc/skel/.bashrc
cp /etc/skel/.bashrc /etc/skel/.bash_profile


#check if group exists
groupadd -g 100000 wsusers
echo "AllowGroups users wsusers mkijowski" >> /etc/ssh/sshd_config

#may not be necessary if we fix sssd, WSU thinks tcsh is default sh
ln -sfb /bin/bash /bin/tcsh

#check if dir exists
mkdir -p /etc/sssd

if [ -f $SSSDCONF ]; then
    cp $SSSDCONF /etc/sssd/sssd.conf
else
    echo "No sssd.conf found, creating blank file for permissions"
    touch /etc/sssd/sssd.conf
fi

cp ./ssh_config  /etc/ssh/ssh_config
cp ./sshd_config /etc/ssh/sshd_config

chown root:root /etc/sssd/sssd.conf
chmod 700 /etc/sssd/sssd.conf

apt update && apt install -y sssd

cat ./common-session.ed | ed - /etc/pam.d/common-session

service sssd restart
service ssh restart
service sshd restart
