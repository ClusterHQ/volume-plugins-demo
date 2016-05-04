# Docker - Flocker - UCP - Workshop

Based on: https://docs.docker.com/ucp/production-install/

Helpful links
=============
https://clusterhq.com/2016/04/29/docker-boston-april/
https://clusterhq.com/2016/03/10/fun-with-swarm-part2/
https://clusterhq.com/2016/03/09/fun-with-swarm-part1/

# Getting Started

- Sign up for [DockerHub](https://hub.docker.com/)
- Once logged in, choose **Settings** (on top right), then click the Licenses Tab
- Create license if there is not one there by clicking the link or visiting https://hub.docker.com/enterprise/trial/ 
- Create the license and select **attach to DockerHub account**
- Fill out the form and click **Start Trial**
- Download License and save to host.

## What you will need.

- Git
- Docker Toolbox
- Vagrant

## Getting started

Open a terminal and download the repo.
```
$ git clone -b ucp https://github.com/wallnerryan/volume-plugins-demo
$ cd volume-plugins-demo
```

Install the environment
```
$ vagrant up
```

After this completes, you will have two Flocker + Docker Nodes. Before you install UCP, lets get our Docker daemon ready for clustering.

```
$ ./swarm/ready-docker-for-swarm.sh
Restarting the Docker Daemon on node2
docker stop/waiting
docker start/running, process 3280
```

Install UCP

**Node1**
```
$ vagrant ssh node1
node1$ docker run --rm -it --name ucp \
-v /var/run/docker.sock:/var/run/docker.sock \
docker/ucp install \
--fresh-install \
--host-address=172.16.78.250 \
--san node1
```

Once, complete, navigate to https://172.16.78.250/#/login

> Note: login with admin/orca

Next, upload the `.lic` license you have for Docker UCP

Next,output the fingerprint for your Controller

> Note: copy the output to your clipboard

```
node1$ docker run --rm \
    --name ucp \
    -v /var/run/docker.sock:/var/run/docker.sock \
    docker/ucp \
    fingerprint
SHA1 Fingerprint=DA:C3:17:13:9B:50:A5:87:AE:D5:D7:46:CE:61:38:DA:2C:04:6B:9A
```

**Node2**

Next, on node2 we can add the node to our UCP cluster.

```
$ vagrant ssh node2

node2$ docker run --rm -it --name ucp \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e UCP_ADMIN_USER=admin -e UCP_ADMIN_PASSWORD=orca \
  docker/ucp join \
  --fresh-install \
  --san node2 \
  --host-address 172.16.78.251 \
  --url https://172.16.78.250 \
  --fingerprint <SHA1 Fingerprint you copied before>
```

After this completes, navigate back to the dashboard and verify you have 2 nodes.
https://172.16.78.250/#/dashboard

# Demos

## Before you run the demos

You may want to install the CLI access to talk to your Swarm cluster, if so, here is how.

1. Navigate to your UCP server in your web browser

2. In the upper right corner click `admin` and choose `Profile`

3. Click `Create a Client Bundle`

4. Navigate to where the bundle was downloaded, and unzip the client bundle

```
$ cp ~/Downloads/ucp-bundle-admin.zip .
$ unzip bundle.zip
Archive:  bundle.zip
extracting: ca.pem
extracting: cert.pem
extracting: key.pem
extracting: cert.pub
extracting: env.sh
```

5. Change into the directory that was created when the bundle was unzipped

6. Execute the `env.sh` script to set the appropriate environment variables for         your UCP deployment

```
$ source env.sh
```

7. Run `docker info` to examine the configuration of your Docker Swarm. Your output should show that you are managing the swarm vs. a single node.

```
$ docker info
 Containers: 9
 Running: 9
 Paused: 0
 Stopped: 0
Images: 24
Server Version: swarm/1.1.3
Role: primary
Strategy: spread
Filters: health, port, dependency, affinity, constraint
Nodes: 2
 node1: 172.16.78.250:12376
  └ Status: Healthy
  └ Containers: 7
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 1.536 GiB
  └ Labels: executiondriver=, kernelversion=3.13.0-85-generic, operatingsystem=Ubuntu 14.04.4 LTS, storagedriver=aufs
  └ Error: (none)
  └ UpdatedAt: 2016-05-03T19:46:20Z
 node2: 172.16.78.251:12376
  └ Status: Healthy
  └ Containers: 2
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 1.536 GiB
  └ Labels: executiondriver=, kernelversion=3.13.0-85-generic, operatingsystem=Ubuntu 14.04.4 LTS, storagedriver=aufs
  └ Error: (none)
  └ UpdatedAt: 2016-05-03T19:46:06Z
Cluster Managers: 1
 172.16.78.250: Healthy
  └ Orca Controller: https://172.16.78.250:443
  └ Swarm Manager: tcp://172.16.78.250:2376
  └ KV: etcd://172.16.78.250:12379
Plugins:
 Volume:
 Network:
Kernel Version: 3.13.0-85-generic
Operating System: linux
Architecture: amd64
CPUs: 2
Total Memory: 3.072 GiB
Name: ucp-controller-node1
ID: N7UO:47D6:LJTN:XMME:7MK4:4CG7:WBXO:F7GX:ZJQR:PD6U:WXPX:FBPS
Labels:
 com.docker.ucp.license_key=kC4fTVzI1IW6w6SmaYALxRwL506maBBJyqz_QzDIvC65
 com.docker.ucp.license_max_engines=10
 com.docker.ucp.license_expires=2016-06-02 17:25:40 +0000 UTC
```

## Demo 1 showing data movement across nodes

1. Navigate to the dashboard and click the Volume tab from the menu
2. Create a volume with the inputs of `flocker` as the driver and `size=10G` as the option. Use whatever name you would like.
3. Navigate to the Containers tab from the dashboar menu
4. Create a container with the image `busybox` and config `touch /data/Hello` for the command and the name of your volume mapped to `/data` in Volumes. Set the constraint to `node==node1` and run the container.
5. Delete that container after it runs
6. Create another container with the image `busybox` and config `ls /data/` for the command and the name of your volume mapped to `/data` in Volumes. Set the constraint to `node==node2` so it runs on a different host and run the container. Click on container after it runs and click again on the Logs tab for that container, you should see `Hello` in the output showing that data has moved from one host to the other.
7. Delete that container.

For better visuals for this demo, see the slides provided.

## Demo 2 running compose app with HA data

> Note, this demo assumes you have the CLI portion setup and you are able to run `docker <cmds>` against your UCP cluster.

1. Go to the `app/` folder.
```
$ cd app/
$ ls
docker-compose.yml
```

2. Run the app.
```
run the app
$ docker-compose -f docker-compose-node2.yml up -d
Creating app_redis_1
Creating app_web_1
```

3. Navigate to https://172.16.78.250/#/applications to see your app. Click on "show containers" next to the app.

4. See which node your web interface is running on
```
$ docker-compose ps
   Name                  Command               State            Ports
-------------------------------------------------------------------------------
app_redis_1   docker-entrypoint.sh redis ...   Up      6379/tcp
app_web_1     node index.js                    Up      172.16.78.251:80->80/tcp
```

5. Navigate to http://172.16.78.251 and click the page to add docker images.

6. See node2 is running the containers.
```
$ docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS                      NAMES
5e913397fc51        binocarlos/moby-counter:latest   "node index.js"          About an hour ago   Up 25 seconds       172.16.78.251:80->80/tcp   node2/app_web_1
6787fc5a1ef8        redis:latest                     "docker-entrypoint.sh"   About an hour ago   Up 25 seconds       6379/tcp                   node2/app_redis_1
```

7. Delete the app and remove the containers.
```
docker-compose -f docker-compose-node2.yml stop
docker-compose -f docker-compose-node2.yml rm -f
```

8. Redeploy the app on `node1`.

Bring up the app
```
docker-compose -f docker-compose-node1.yml up -d
```

See that is on `node1` now. Visit http://172.16.78.250/, you should see the same images as before. Data movement!
```
$ docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED              STATUS              PORTS                      NAMES
52419b5570c0        binocarlos/moby-counter:latest   "node index.js"          About a minute ago   Up About a minute   172.16.78.250:80->80/tcp   node1/app_web_1
49b57f562c41        redis:latest                     "docker-entrypoint.sh"   About a minute ago   Up About a minute   6379/tcp                   node1/app_redis_1
```

## Demo 3 showing HA data movement with Redis

Start a redis server with rescheduling enabled.
```
$ docker run -d --name=redis-server \
  --volume-driver=flocker \
  -v testfailover:/data \
  --restart=always \
  -e constraint:node==node2 \
  -e reschedule:on-node-failure  \
  redis redis-server --appendonly yes
9329267d13664448495064ffb87089755ed5c6fc13297a02c779c5bd8b58284c
```

Check the cluster for out redis-server
```
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
9329267d1366        redis               "docker-entrypoint.sh"   3 seconds ago       Up 2 seconds        6379/tcp            node2/redis-server
```

Verify its using a Flocker volume
```
$ docker inspect -f "{{.Mounts}}" redis-server
[{testfailover /flocker/a5ae6638-0d11-4d2a-91ac-3e5b931419d4.default.0f0d0ff8-aef9-4823-99fb-6b2f14bd8d91 /data flocker  true rprivate}]
```

See our volume
```
$ docker volume ls
DRIVER              VOLUME NAME
flocker             testfailover
```

Add some data
```
$ docker exec -it redis-server /bin/bash
root@badab324e09a:/data# redis-cli
redis-server:6379>
redis-server:6379> SET mykey "Hello"
OK
redis-server:6379> GET mykey
"Hello"
redis-server:6379> exit
```
> Notice: redis-server is running on `node2` right now

"Fail" the container.
```
docker kill redis-server && docker rm -f redis-server
```

> Note: UCP at its current version does not have Swarm auto-rescheduling, so HA is not going to work automatically here. Swarm auto-rescheduling is added in Swarm `1.2.0`, UCP Latest runs at `ucp-swarm:1.0.4.` To see auto-failove, please see this video https://asciinema.org/a/44008?t=20:14 for how this works with the last Swarm features.

Once our container is gone, we can create our redis-server again. Normally this is automatic for the orchestration platform.

```
$ docker run -d --name=redis-server \
  --volume-driver=flocker \
  -v testfailover:/data \
  --restart=always \
  -e constraint:node==node1 \
  -e reschedule:on-node-failure  \
  redis redis-server --appendonly yes
9329267d13664448495064ffb87089755ed5c6fc13297a02c779c5bd8b58284c
```

And we have HA for our data, its still there.
```
$ docker exec -it redis-server /bin/bash
root@badab324e09a:/data# redis-cli
redis-server:6379> GET mykey
"Hello"
```


