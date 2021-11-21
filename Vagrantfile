# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

ENV["LC_ALL"] = "en_US.UTF-8"

NODE_1_DISK = "/apple_hdd/hdds/node_1_hdd.vdi"
NODE_2_DISK = "/apple_hdd/hdds/node_2_hdd.vdi"
NODE_3_DISK = "/apple_hdd/hdds/node_3_hdd.vdi"
NODE_4_DISK = "/apple_hdd/hdds/node_4_hdd.vdi"

PERSONAL_1_DISK = "/media/vms/personal_1_hdd.vdi"

Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.


# 루프 돌지 않고 하기
#	(1..4).each do |i|
#		config.vm.define "node=#{i}" do |node|
#			node.vm.provision "shell",
#				inline: "echo hello from node #{i}"
#
#			node.vm.network "private_network", ip: "192.168.50.#{i}"
#		end
#	end


# 그냥 하기
	config.vm.define "node_1" do |node1|
		node1.vm.box = "centos/7"
		node1.vm.host_name = "node1"

		node1.vm.network "private_network", ip: "192.168.50.11"

		node1.vm.provider :virtualbox do |vb|
			vb.cpus = 2
			vb.memory = 4096
			vb.gui = false

			if !File.exist?(NODE_1_DISK)
				vb.customize ['createmedium', '--filename', NODE_1_DISK, '--size', 10 * 1024, '--variant', 'Standard'] # 10G
			end
			vb.customize ['storageattach', :id, '--storagectl', 'IDE', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', NODE_1_DISK]
		end

	end

	config.vm.define "node_2" do |node2|
                node2.vm.box = "centos/7"
                node2.vm.host_name = "node2"

		node2.vm.network "private_network", ip: "192.168.50.12"

                node2.vm.provider :virtualbox do |vb|
                        vb.cpus = 2
                        vb.memory = 4096
			vb.gui = false

			unless File.exist?(NODE_2_DISK)
                                vb.customize ['createhd', '--filename', NODE_2_DISK, '--size', 10 * 1024, '--variant', 'Standard'] # 10G
                        end
                        vb.customize ['storageattach', :id, '--storagectl', 'IDE', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', NODE_2_DISK]
		end

        end

	config.vm.define "node_3" do |node3|
                node3.vm.box = "centos/7"
                node3.vm.host_name = "node3"

		node3.vm.network "private_network", ip: "192.168.50.13"

                node3.vm.provider :virtualbox do |vb|
                        vb.cpus = 2
                        vb.memory = 4096
			vb.gui = false

			unless File.exist?(NODE_3_DISK)
                                vb.customize ['createhd', '--filename', NODE_3_DISK, '--size', 10 * 1024, '--variant', 'Standard'] # 10G
                        end
                        vb.customize ['storageattach', :id, '--storagectl', 'IDE', '--port', 0, '--device', 0, '--type', 'hdd', '--medium', NODE_3_DISK]
		end

        end

	config.vm.define "node_4" do |node4|
                node4.vm.box = "centos/7"
                node4.vm.host_name = "node4"

		node4.vm.network "private_network", ip: "192.168.50.14"

                node4.vm.provider :virtualbox do |vb|
                        vb.cpus = 2
                        vb.memory = 4096
			vb.gui = false
		end

		# for PVC
		node4.vm.synced_folder "/apple_hdd/synced", "/synced",
			owner: "k8s", group: "k8s"
        end

	config.vm.define "personal_1" do |p1|
                p1.vm.box = "ubuntu/focal64"
                p1.vm.host_name = "personal1"

		p1.vm.network "public_network"

                p1.vm.provider :virtualbox do |vb|
                        vb.cpus = 4
                        vb.memory = 16384 # 16G
			vb.gui = false
		end

		p1.vm.synced_folder "/media/synced", "/synced",
			owner: "vagrant", group: "vagrant"
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

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
