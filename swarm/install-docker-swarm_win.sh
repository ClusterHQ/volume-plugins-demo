#!/bin/bash
# To by used with Cygwin on windows
# This script locks in Swarm at the below version
SWARM_VERSION=1.2.0
echo "Installing Consul on node1"
vagrant ssh node1 -c "sudo docker rm -f consul-server"
vagrant ssh node1 -c "sudo docker run -d \
    -p "8500:8500" \
    -h "consul" \
    --name=consul-server \
    --restart=always \
    progrium/consul -server -bootstrap"
# wait for consul to come up
sleep 5
echo "Installing Swarm Manager on node1"
vagrant ssh node1 -c "sudo docker rm -f swarm-manager1"
vagrant ssh node1 -c "sudo docker run -d \
    --name=swarm-manager1 \
    --restart=always \
    -p 3375:3375 swarm:$SWARM_VERSION manage \
    --host=0.0.0.0:3375 \
    --replication --advertise 172.16.78.250:3375 \
    consul://172.16.78.250:8500"
echo "Installing Swarm Manager on node2"
vagrant ssh node2 -c "sudo docker rm -f swarm-manager2"
vagrant ssh node2 -c "sudo docker run -d \
    --name=swarm-manager2 \
    --restart=always \
    -p 3375:3375 swarm:$SWARM_VERSION manage \
    --host=0.0.0.0:3375 \
    --replication --advertise 172.16.78.251:3375 \
    consul://172.16.78.250:8500"
echo "Installing Swarm Agent on node1"
vagrant ssh node1 -c "sudo docker rm -f swarm-agent1"
vagrant ssh node1 -c "sudo docker run -d \
   --name=swarm-agent1 \
   --restart=always swarm:$SWARM_VERSION join \
   --advertise=172.16.78.250:2375 \
   consul://172.16.78.250:8500"
echo "Installing Swarm Agent on node2"
vagrant ssh node2 -c "sudo docker rm -f swarm-agent2"
vagrant ssh node2 -c "sudo docker run -d \
   --name=swarm-agent2 \
   --restart=always swarm:$SWARM_VERSION join \
   --advertise=172.16.78.251:2375 \
   consul://172.16.78.250:8500"
echo "Done: Swarm available at tcp://172.16.78.250:3375"
