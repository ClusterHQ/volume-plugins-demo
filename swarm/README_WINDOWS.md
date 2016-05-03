

To install the demo on windows, do the vollowing.

## What you need.

Install Docker Toolbox for Windows
[https://www.docker.com/products/docker-toolbox](https://www.docker.com/products/docker-toolbox)

Install Vagrant for Windows
[https://www.vagrantup.com/downloads.html](https://www.vagrantup.com/downloads.html)

Install Cygwin for Windows (with Net/openssh and Devel/git components)
[https://www.cygwin.com/](https://www.cygwin.com/)


> Note: after vagrant installation, please logoff and logon for the `vagrant` command to be added to your path correctly.

## How to install

> Note: if vagrant errs out downloading the box and you're on windows sever 2012, you may need to install `Microsoft Visual C++ 2010 SP1 Redistributable Package (x86)` [here](http://www.microsoft.com/en-us/download/details.aspx?id=8328) according to [this github comment](https://github.com/mitchellh/vagrant/issues/6754#issuecomment-168856576)

Open `Cygwin64 Terminal` in Windows
```
git clone -b swarm https://github.com/wallnerryan/volume-plugins-demo
cd volume-plugins-demo
vagrant up
```

To install swarm
```
./swarm/ready-docker-for-swarm_win.sh
./swarm/install-docker-swarm_win.sh
Done: Swarm available at tcp://172.16.78.250:3375
```
