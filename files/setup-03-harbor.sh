#!/bin/bash

# Generate a CA certificate private key
openssl genrsa -out ca.key 4096

# Generate the CA certificate
openssl req -x509 -new -nodes -sha512 -days 3650 \
    -subj "/C=US/ST=California/L=Palo Alto/CN=${HOSTNAME}" \
    -key ca.key \
    -out ca.crt

# Generate a private key
openssl genrsa -out ${HOSTNAME}.key 4096

# Generate a certificate signing request (CSR)
openssl req -sha512 -new \
    -subj "/C=US/ST=California/L=Palo Alto/CN=${HOSTNAME}" \
    -key ${HOSTNAME}.key \
    -out ${HOSTNAME}.csr

# Generate an x509 v3 extension file
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=${HOSTNAME}
DNS.2=${DNS_DOMAIN}
EOF

# Generate a certificate for your Harbor host using v3.ext
openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in ${HOSTNAME}.csr \
    -out ${HOSTNAME}.crt

# Configure certificate for Docker
mkdir -p /data/cert/
cp ${HOSTNAME}.crt /data/cert/
cp ${HOSTNAME}.key /data/cert/

openssl x509 -inform PEM -in ${HOSTNAME}.crt -out ${HOSTNAME}.cert

mkdir -p /etc/docker/certs.d/${HOSTNAME}/
cp ${HOSTNAME}.cert /etc/docker/certs.d/${HOSTNAME}/
cp ${HOSTNAME}.key /etc/docker/certs.d/${HOSTNAME}/
cp ca.crt /etc/docker/certs.d/${HOSTNAME}/

# Creating Harbor configuration
HARBOR_CONFIG=harbor.yml
cd /root/harbor
mv /root/harbor/harbor.yml.tmpl /root/harbor/${HARBOR_CONFIG}
sed -i "s/hostname:.*/hostname: ${HOSTNAME}/g" ${HARBOR_CONFIG}
sed -i "s/certificate:.*/certificate: \/etc\/docker\/certs.d\/${HOSTNAME}\/${HOSTNAME}.cert/g" ${HARBOR_CONFIG}
sed -i "s/private_key:.*/private_key: \/etc\/docker\/certs.d\/${HOSTNAME}\/${HOSTNAME}.key/g" ${HARBOR_CONFIG}
sed -i "s/harbor_admin_password:.*/harbor_admin_password: ${HARBOR_PASSWORD}/g" ${HARBOR_CONFIG}
sed -i "s/password:.*/password: ${HARBOR_PASSWORD}/g" ${HARBOR_CONFIG}

# Installing Harbor
./install.sh
rm -f harbor.*.gz

# Waiting for Harbor to be ready, sleeping for 90 seconds
sleep 90