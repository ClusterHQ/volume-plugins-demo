## Volume Plugins Demo

Using Docker 1.8 Volume Plugins with Compose and Flocker.

### The problem

You have just created an amazing new web application and are ready to show to world!  Because it is a small project with a limited budget, you decided to deploy it onto some modest servers and gather feedback before committing resources to more powerful servers.

However, the submission to Hacker News went much better than expected and your new application is at the top of the front page!  This has created a surge in traffic and your modest little server just does not have the power to cope with the demands your database is putting onto it.

You will need to migrate your application, database and data to a server with:

 * more memory
 * a faster CPU
 * SSD drives

Because we are using [Docker](https://github.com/docker/docker) together with [Docker Compose](https://github.com/docker/compose) - it means we can very quickly spin up the web application and database **containers** onto another more powerful machine.

However - we also need to move the **data** otherwise disaster will strike and all our users will leave.

### The solution

Using [Docker 1.8 plugins](https://github.com/docker/docker/blob/master/docs/extend/plugins.md) together with [Flocker](https://clusterhq.com/) - we are able to migrate the containers **AND** the data using nothing other than `docker-compose` commands.

This demonstrates how the phrase:

> batteries included but removable 

Has become a reality and in the case of Volume drivers - have made it out of the `experimental` phase and into mainstream docker.

We will use the [Flocker Plugin](https://github.com/clusterhq/flocker-docker-plugin) together with the new `--volume-driver` flag to migrate the database container and data as a single, atomic unit.

## Demo

First we will demonstrate some basic Docker CLI commands that make use of `--volume-driver` so we can see how this great new feature of Docker works.

Then, we will use Docker Compose to spin up our application on the first node, create some data and then move it to the second node and witness Flocker migrating the data alongside the database container - all using nothing but `docker-compose`.

### Install

First you need to install:

 * [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
 * [Vagrant](http://www.vagrantup.com/downloads.html)

*We’ll use [Virtualbox](https://www.virtualbox.org/wiki/Downloads) to supply the virtual machines that our cluster will run on.*

*We’ll use [Vagrant](http://www.vagrantup.com/downloads.html) to simulate our application stack locally. You could also run this demo on AWS or Rackspace with minimal modifications.*

### Step 1: Start VMs

The first step is to clone this repo and start the VMs:

```bash
$ git clone https://github.com/clusterhq/volume-plugins-demo
$ cd volume-plugins-demo
$ vagrant up
```

### Step 2: Check Docker version

We are then going to confirm that we are actually running Docker 1.8 and that it is the non-experimental version:

```bash
$ vagrant ssh node1
vagrant@node1:~$ docker version

Client:
 Version:      1.8.0-dev
 API version:  1.21
 Go version:   go1.4.2
 Git commit:   1027247
 Built:        Mon Aug  3 18:04:07 UTC 2015
 OS/Arch:      linux/amd64

Server:
 Version:      1.8.0-dev
 API version:  1.21
 Go version:   go1.4.2
 Git commit:   1027247
 Built:        Mon Aug  3 18:04:07 UTC 2015
 OS/Arch:      linux/amd64

vagrant@node1:~$ exit
```

NOTE - the version of this binary is `1.8.0-dev` because this blog post was put together a few days before the official release.

### Step 3: Write some data to node1

Now we use the `--volume-driver flocker` flag to write some data to a Flocker volume:

```bash
$ vagrant ssh node1
vagrant@node1:~$ docker run --rm \
    --volume-driver flocker \
    -v simple:/data \
    busybox sh -c "echo hello > /data/file.txt"
vagrant@node1:~$ exit
```

### Step 4: Read the data from node2

Now lets try to read the same data but from a totally different server!  Flocker will migrate the data in place before the container is run:

```bash
$ vagrant ssh node2
vagrant@node2:~$ docker run --rm \
    --volume-driver flocker \
    -v simple:/data \
    busybox sh -c "cat /data/file.txt"
hello
vagrant@node2:~$ exit
```

### Step 5: Run the application on node1

Next we will use Docker Compose to spin up our web application on the first node:

```bash
$ vagrant ssh node1
vagrant@node1:~$ cd /vagrant/app
vagrant@node1:~$ docker-compose up -d
vagrant@node1:~$ exit
```

### Step 6: Load the application in a browser

Now we can fire up a web-browser and visit:

```
http://172.16.78.250
```

You should see a blank page - try clicking around to create some Moby Docks!

### Step 7: Stop the application on node1

Next lets stop the application running on node1:

```bash
$ vagrant ssh node1
vagrant@node1:~$ cd /vagrant/app
vagrant@node1:~$ docker-compose stop
vagrant@node1:~$ exit
```

### Step 8: Run the application on node2

Now the cool part - lets SSH to node2 and use `docker-compose` just like we did on node1.  The difference is this time - Flocker will migrate the data we created on node1 alongside the database container:

```bash
$ vagrant ssh node2
vagrant@node2:~$ cd /vagrant/app
vagrant@node2:~$ docker-compose up -d
vagrant@node2:~$ exit
```

### Step 9: Load the application in a browser

Now we can fire up a web-browser and visit:

```
http://172.16.78.251
```

This time - we should see the same data we created on node1.  This means that docker-compose has given docker the `--volume-driver flocker` argument and Flocker has kicked in behind the scenes to migrate the data onto node2!

NOTE: The URL is different this time because we have moved the application to node2.  I have kept DNS and load-balancing out of this demo to keep it as simple and to the point as possible.


### Step 10: Confirm the application is running on node2

As a final confirmation that our application is migrated we can ask Docker to list the containers it is running on node2:

```bash
$ vagrant ssh node2
vagrant@node2:~$ docker ps

CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS                NAMES
38e1920d3994        binocarlos/moby-counter:latest   "node index.js"          25 seconds ago      Up 25 seconds       0.0.0.0:80->80/tcp   app_web_1
2a84d6a262ff        redis:latest                     "/entrypoint.sh redis"   31 seconds ago      Up 25 seconds       6379/tcp             app_redis_1

vagrant@node2:~$ exit
```

## Conclusion

Using this very basic demo, we were able to show that the plugin mechanism in Docker 1.8 is able to integrate with both Flocker and Docker Compose allowing us to migrate a stateful web application from one server to another.

You can read more about Flocker at the [ClusterHQ](https://clusterhq.com) website where you can try a free online version with no setup!

## run tests

To run the tests:

```bash
$ make test
```

## build box

To build the box from which the Vagrantfile is based:

```bash
$ make box
```

This will produce a `vagrantXXXXXX.box` file inside the box directory where XXXX is the current timestamp.  You can then upload this box to a cloud provider and update the top level Vagrantfile to load it.
