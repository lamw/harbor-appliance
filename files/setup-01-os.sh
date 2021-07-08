#!/bin/bash

# OS Specific Settings where ordering does not matter

set -euo pipefail

# Enable & Start SSH
systemctl enable sshd
systemctl start sshd

# Allow ICMP
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables-save > /etc/systemd/scripts/ip4save

# Ensure docker is stopped to allow config of network
systemctl stop docker

echo -e "\e[92mConfiguring OS Root password ..." > /dev/console
echo "root:${ROOT_PASSWORD}" | /usr/sbin/chpasswd

if [ "${DOCKER_NETWORK_CIDR}" != "172.17.0.1/16" ]; then
    echo -e "\e[92mConfiguring Docker Bridge Network ..." > /dev/console
    cat > /etc/docker/daemon.json << EOF
{
    "bip": "${DOCKER_NETWORK_CIDR}",
    "log-opts": {
        "max-size": "10m",
        "max-file": "5"
    }
}
EOF
fi

# Start Docker
systemctl start docker