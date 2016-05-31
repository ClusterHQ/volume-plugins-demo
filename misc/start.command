# enter directory
mkdir ~/dockercon-demo/
cd ~/dockercon-demo/

# add the code
git clone -b ucp https://github.com/ClusterHQ/volume-plugins-demo
cd volume-plugins-demo

# start the env
vagrant up

echo ""
echo "Ready, enjoy the demo!"
echo ""

/bin/bash
