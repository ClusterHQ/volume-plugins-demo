## What you need.

Install Docker Toolbox 
[https://www.docker.com/products/docker-toolbox](https://www.docker.com/products/docker-toolbox)

Install Vagrant
[https://www.vagrantup.com/downloads.html](https://www.vagrantup.com/downloads.html)

## How to install

```
git clone -b swarm https://github.com/wallnerryan/volume-plugins-demo
cd volume-plugins-demo
vagrant up
```

To install swarm
```
./swarm/ready-docker-for-swarm.sh
./swarm/install-docker-swarm.sh
Done: Swarm available at tcp://172.16.78.250:3375
```

Use Swarm
```
export DOCKER_HOST=tcp://172.16.78.250:3375
docker info
```
