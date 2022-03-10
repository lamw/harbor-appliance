#!/bin/bash -eux

##
## Misc configuration
##

echo '> Disable IPv6'
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf

echo '> Applying latest Updates...'
sudo sed -i 's/dl.bintray.com\/vmware/packages.vmware.com\/photon\/$releasever/g' /etc/yum.repos.d/*.repo
tdnf -y update photon-repos
tdnf clean all
tdnf makecache
tdnf -y update

echo '> Installing Additional Packages...'
tdnf install -y \
  logrotate \
  wget \
  unzip \
  tar

echo '> Creating directory for setup scripts'
mkdir -p /root/setup

echo ' > Downloading Harbor...'
HARBOR_VERSION=2.4.1
curl -L https://github.com/goharbor/harbor/releases/download/v${HARBOR_VERSION}/harbor-offline-installer-v${HARBOR_VERSION}.tgz -o harbor-offline-installer-v${HARBOR_VERSION}.tgz
tar xvzf harbor-offline-installer*.tgz
rm -f harbor-offline-installer-v${HARBOR_VERSION}.tgz

echo '> Downloading docker-compose...'
DOCKER_COMPOSE_VERSION=2.3.3
curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose