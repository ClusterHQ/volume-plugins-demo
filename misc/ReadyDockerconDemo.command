# ***REMOVE AND DESTROY ANYTHING OLD***

# Kill oldest processes of the two.
# This should be ones open from previous demos
pkill -o firefox
rm -rf ~/Library/Caches/Firefox/Profiles/qn53jin6.default/startupCache
rm -rf ~/Library/Caches/Firefox/Profiles/qn53jin6.default/cache2
osascript -e 'tell application "Terminal"' -e 'set mainID to id of front window' -e 'close (every window whose id ≠ mainID)' -e 'end tell'


#  Remove directory directory
cd ~/dockercon-demo/volume-plugins-demo/
vagrant destroy -f
cd ~/
rm -rf  ~/dockercon-demo
rm ~/Downloads/ucp-bundle*

#Close safari and Terminal
pkill firefox
# *** END REMOVE AND DESTROY***

# *** START NEW ENVIRONMENT ***
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

open -a "Firefox" https://gist.github.com/wallnerryan/255bc1f68c9b76f641de48a5f2cf192e
open -a "Firefox" https://node1:443 

echo ""
echo "*********************************************************************"
echo "|-------------------------------------------------------------------|"
echo "| Ready, enjoy the demo! Start with Step 1 of the self-guided demo! |"
echo "|-------------------------------------------------------------------|"
echo "*********************************************************************"
echo ""

/bin/bash
