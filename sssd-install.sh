#!/bin/bash

##check if root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root, exiting."
   exit 1
fi

#fix /etc/skel
mkdir /etc/skel/.ssh
touch /etc/skel/.ssh/authorized_keys
echo "/home/$USER/.mk-ssh-key" >> /etc/skel/.bashrc
cp ./mk-ssh-key.sh /etc/skel/.mk-ssh-key

#check if group exists
groupadd -g 100000 wsusers
echo "AllowGroups users wsusers mkijowski" >> /etc/ssh/sshd_config

#may not be necessary if we fix sssd, WSU thinks tcsh is default sh
ln -sfb /bin/bash /bin/tcsh

#check if dir exists
mkdir -p /etc/sssd

if [ -f /home/conf/sssd.conf ]; then
    cp /home/conf/sssd.conf /etc/sssd/sssd.conf
else
    echo "No sssd.conf found, creating blank file for permissions"
    touch /etc/sssd/sssd.conf
fi

chown root:root /etc/sssd/sssd.conf
chmod 700 /etc/sssd/sssd.conf

apt update && apt install -y sssd

cat ./common-session.ed | ed - /etc/pam.d/common-session

service sssd restart

