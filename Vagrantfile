# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

load 'scripts.rb'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

  config.vm.box = "volume-plugins-demo-vagrant-ubuntu-v3"
  config.vm.box_url = "https://s3.amazonaws.com/clusterhq-public-vagrant/boxes/volume-plugins-demo-vagrant-ubuntu-v3.box"

  config.vm.define "node1" do |node1|
    node1.vm.network :private_network, :ip => "172.16.78.250"
    node1.vm.hostname = "node1"
    node1.vm.provider "virtualbox" do |v|
      v.memory = 1536
    end

    # these functions are all defined in 'scripts.rb'
    node1.vm.provision :shell, inline:
      create_zfs_pool() +
      add_vagrant_group() +
      install_ssh_keys() +
      copy_control_certs() +
      copy_agent_certs("node1") +
      flocker_control_config() +
      flocker_agent_config("172.16.78.250") +
      flocker_plugin_config()

  end

  config.vm.define "node2" do |node2|
    node2.vm.network :private_network, :ip => "172.16.78.251"
    node2.vm.hostname = "node2"
    node2.vm.provider "virtualbox" do |v|
      v.memory = 1536
    end

    # these functions are all defined in 'scripts.rb'
    node2.vm.provision :shell, inline:
      create_zfs_pool() +
      add_vagrant_group() +
      install_ssh_keys() +
      copy_agent_certs("node2") +
      flocker_agent_config("172.16.78.250") +
      flocker_plugin_config()

  end

end
