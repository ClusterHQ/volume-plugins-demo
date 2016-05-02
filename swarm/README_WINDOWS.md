

To install the demo on windows, do the vollowing.

## What you need.

Install Docker Toolbox for Windows
[https://www.docker.com/products/docker-toolbox](https://www.docker.com/products/docker-toolbox)

Install Vagrant for Windows
[https://www.vagrantup.com/downloads.html](https://www.vagrantup.com/downloads.html)

Install Cygwin for Windows (with Net/*ssh* components)
[https://www.cygwin.com/](https://www.cygwin.com/)


> Note: after vagrant installation, please logoff and logon for the `vagrant` command to be added to your path correctly.

## How to install

Open `Git Bash` in Windows
```
git clone -b swarm https://github.com/wallnerryan/volume-plugins-demo
```

Open `Cygwin64 Terminal` in Windows
```
cd /cygdrive/d/Users/<USERNAME>/volume-plugins-demo/
vagrant up
```

To install swarm
```
sh swarm/ready-docker-for-swarm_win.sh
sh swarm/ready-docker-for-swarm_win.sh
```
