# -*- mode: ruby -*-
# vi: set ft=ruby :

if ENV['NODES']
  nodes=ENV['NODES'].to_i
else
  nodes=4
end

first_three_network_octets = "192.168.122"
master_ip_number = 10

Vagrant.configure("2") do |config|
  config.vm.box = "centos/atomic-host"

  config.vm.define :master, autostart: false do |master|
    master.vm.hostname = "kube-master"
    master.vm.network "private_network", ip: "#{first_three_network_octets}.#{master_ip_number}"
    master.vm.provision :file, source: "master/config", destination: "/tmp/master_config"
    master.vm.provision :shell, path: "master/setup.sh"
    master.vm.provider :virtualbox do |v|
      v.memory = 2048
      v.cpus = 2
    end
    master.vm.provider :libvirt do |v|
      v.memory = 2048
      v.cpus = 2
    end
  end

  (1..nodes).each do |node_number|
    # Calculate ip address for node
    node_ip = "#{first_three_network_octets}.#{master_ip_number + node_number}"
    config.vm.define "node#{node_number}", autostart: true do |node|
      node.vm.hostname = "kube-node#{node_number}"
      node.vm.network "private_network", ip: node_ip
      node.vm.provision :file, source: "node/config", destination: "/tmp/node_config"
      node.vm.provision :shell, path: "node/setup.sh", args: node_ip
      node.vm.provider :virtualbox do |v|
        v.memory = 512
        v.cpus = 1
      end
      node.vm.provider :libvirt do |v|
        v.memory = 512
        v.cpus = 1
      end
    end
  end

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
