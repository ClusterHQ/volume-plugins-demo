#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
set -ex

# remove chef and puppet
apt-get -y autoremove chef puppet

# install flocker
apt-get -y install apt-transport-https software-properties-common
add-apt-repository -y ppa:james-page/docker
add-apt-repository -y "deb https://clusterhq-archive.s3.amazonaws.com/ubuntu/$(lsb_release --release --short)/\$(ARCH) /"
apt-get update
apt-get -y --force-yes install clusterhq-flocker-node clusterhq-flocker-cli

# install flocker plugin
apt-get -y install python-pip python-dev
pip install git+https://github.com/clusterhq/flocker-docker-plugin@master

# install compose
curl -L https://github.com/docker/compose/releases/download/1.4.0rc3/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# install aufs
apt-get install -y linux-image-extra-$(uname -r)

# install zfs
add-apt-repository -y ppa:zfs-native/stable
apt-get update
apt-get -y install libc6-dev
apt-get -y install zfsutils

# install docker 1.8
stop docker.io
# remove non-aufs storage drivers
rm -rf /var/lib/docker/devicemapper
rm -rf /var/lib/docker/graphdriver
# backup old docker binary
cp /usr/bin/docker /usr/bin/docker-1.6
# grab new docker binary
curl -L https://binaries.dockerproject.org/linux/amd64/docker-1.8.0-dev > /usr/bin/docker
chmod a+x /usr/bin/docker
start docker.io
sleep 5

# pre-pull required docker images
docker pull busybox:latest
docker pull redis:latest
docker pull binocarlos/moby-counter:latest