#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
set -e

do-error() {
  echo "$@" >&2
  exit 1
}

check-entry() {
  local a=$1
  local b=$2

  echo "checking $a == $b"

  if [[ "$a" != "$b" ]]; then
    do-error "$a != $b"
  else
    echo "OK"
  fi
}


setup() {
  vagrant up
  sleep 2
}

teardown() {
  vagrant destroy -f
}

post-moby() {
  local ip=$1
  local data=$2
  echo $data | curl -sS -d @- http://$ip/v1/whales
}

get-mobies() {
  local ip=$1
  curl -sS http://$ip/v1/whales
}

run-basic-test() {
  local id=$(date +%s)

  echo "Writing data to node1"
  vagrant ssh node1 -c "docker run --rm -ti -v data$id:/data --volume-driver flocker busybox sh -c 'echo hello > /data/file.txt'"

  echo "Reading data from node2"
  result=$(vagrant ssh node2 -c "docker run --rm -ti -v data$id:/data --volume-driver flocker busybox sh -c 'cat /data/file.txt'")

  result=${result//$'\n'/}
  result=${result//$'\r'/}
  
  check-entry "hello" "$result"
}

run-compose-test() {
  echo "starting application on node1"
  vagrant ssh node1 -c "cd /vagrant/app && docker-compose up -d"

  # wait for connection
  sleep 5

  echo "writing some data to node1"
  post-moby "172.16.78.250" "100:100"
  post-moby "172.16.78.250" "200:100"
  post-moby "172.16.78.250" "100:200"
  post-moby "172.16.78.250" "200:200"

  echo "stopping application on node1"
  vagrant ssh node1 -c "cd /vagrant/app && docker-compose stop"

  echo "starting application on node2"
  vagrant ssh node2 -c "cd /vagrant/app && docker-compose up -d"

  echo "loading data from node2"
  data=$(get-mobies "172.16.78.251")
  data=${data//$'\n'/}
  data=${data//$'\r'/}

  check-entry '["100:100","200:100","100:200","200:200"]' $data

  echo "stopping application on node2"
  vagrant ssh node2 -c "cd /vagrant/app && docker-compose stop"
}

run-all-tests() {
  setup
  run-basic-test
  run-compose-test
  teardown
}

main() {
  case "$1" in
  basic)              shift; run-basic-test; $@;;
  compose)            shift; run-compose-test; $@;;
  setup)              shift; setup; $@;;
  all)                shift; run-all-tests; $@;;
  *)                  run-all-tests $@;;
  esac
}

main "$@"