#!/bin/bash
# otherwise Swarm complains about duplicate ID. https://github.com/docker/swarm/issues/362
echo "Restarting the Docker Daemon on node2"
vagrant ssh node2 -c "sudo rm /etc/docker/key.json"
vagrant ssh node2 -c "sudo service docker restart"

