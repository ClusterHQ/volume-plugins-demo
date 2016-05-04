#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
set -ex

# remove chef and puppet
apt-get -y autoremove chef puppet

# install flocker
apt-get -y install apt-transport-https software-properties-common
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
apt-get -y update
apt-get -y purge lxc-docker
apt-get -y install docker-engine
add-apt-repository -y "deb https://clusterhq-archive.s3.amazonaws.com/ubuntu/$(lsb_release --release --short)/\$(ARCH) /"
apt-get update
apt-get -y --force-yes install clusterhq-flocker-node clusterhq-flocker-cli  clusterhq-flocker-docker-plugin

# install compose
curl -L https://github.com/docker/compose/releases/download/1.7.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# install aufs
apt-get install -y linux-image-extra-$(uname -r)

# install zfs
add-apt-repository -y ppa:zfs-native/stable
apt-get update
apt-get -y install libc6-dev
apt-get -y install zfsutils

service docker stop
sed -ie 's@.*DOCKER_OPTS=.*@DOCKER_OPTS=\"-H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock\"@' /etc/default/docker
# remove non-aufs storage drivers
rm -rf /var/lib/docker/devicemapper
rm -rf /var/lib/docker/graphdriver
service docker start
sleep 5

# Install FlockerCTL
curl -sSL https://get.flocker.io |sh

# pre-pull required docker images
docker pull busybox:latest
docker pull redis:latest
docker pull binocarlos/moby-counter:latest
docker pull consul:latest
docker pull swarm:1.2.0
