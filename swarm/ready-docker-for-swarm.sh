#!/bin/bash

echo "Setting DOCKER_OPTS on node1"
vagrant ssh node1 -c "sudo sed -ie 's@.*DOCKER_OPTS=.*@DOCKER_OPTS=\"-H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock\"@' /etc/default/docker.io"

echo "Restarting the Docker Daemon on node1"
vagrant ssh node1 -c "sudo service docker.io restart"

echo "Setting DOCKER_OPTS on node2"
vagrant ssh node2 -c "sudo sed -ie 's@.*DOCKER_OPTS=.*@DOCKER_OPTS=\"-H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock\"@' /etc/default/docker.io"

# otherwise Swarm complains about duplicate ID. https://github.com/docker/swarm/issues/362
echo "Restarting the Docker Daemon on node2"
vagrant ssh node2 -c "sudo rm /etc/docker/key.json"
vagrant ssh node2 -c "sudo service docker.io restart"

