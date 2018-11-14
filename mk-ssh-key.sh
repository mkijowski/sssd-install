#!/bin/bash

if [ ! -f /home/$USER/.ssh/id_rsa ]; then
    ssh-keygen -q -t rsa -f /home/$USER/.ssh/id_rsa -N ""
    cat /home/$USER/.ssh/id_rsa.pub >> /home/$USER/.ssh/authorized_keys
fi

