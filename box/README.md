## Box Builder

This folder is used to build a Vagrant box that has the software already installed to run the main demo.

### build box

To build a new box:

```
$ make build
```

This will produce a `package.box` file that should be uploaded to a cloud storage provider.  The URL of the uploaded box should then be inserted into the Vagrantfile at the top level of this repo.