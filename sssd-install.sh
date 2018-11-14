#!/bin/bash


##check if root


#fix /etc/skel
mkdir /etc/skel/.ssh
touch /etc/skel/.ssh/authorized_keys
echo "/home/$USER/.mk-ssh-key" >> /etc/skel/.bashrc
cp ./mk-ssh-key.sh /etc/skel/.mk-ssh-key

#check if group exists
groupadd -g 100000 wsusers
echo "AllowGroups users wsusers mkijowski" >> /etc/ssh/sshd_config

#may not be necessary if we fix sssd, WSU thinks tcsh is default sh
ln -s /bin/bash /bin/tcsh

#check if dir exists
mkdir /etc/sssd
touch /etc/sssd/sssd.conf
chown root:root /etc/sssd/sssd.conf
chmod 700 /etc/sssd/sssd.conf

apt update && apt install -y sssd

#probably should make sure common-session layout is the same in 16.04 and 18.04
cat ./common-session.ed | ed - /etc/pam.d/common-session

service restart sssd

