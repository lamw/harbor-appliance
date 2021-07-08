#!/bin/bash -eux
##
## Enable Docker
##

echo '> Enabling Docker...'

systemctl enable docker
reboot

echo '> Done'

