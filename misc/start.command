# enter directory
mkdir ~/dockercon-demo/
cd ~/dockercon-demo/

# add the code
git clone -b ucp https://github.com/ClusterHQ/volume-plugins-demo
cd volume-plugins-demo

# start the env, including first UCP node.
vagrant up
sh  swarm/ready-docker-for-swarm.sh
vagrant ssh node1 -c "docker run --rm -it --name ucp \
   -v /var/run/docker.sock:/var/run/docker.sock \
   docker/ucp install \
   --fresh-install \
   --host-address=172.16.78.250 \
   --san node1"

echo ""
echo "Ready, enjoy the demo!"
echo ""

/bin/bash
