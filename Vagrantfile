# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

ENV["LC_ALL"] = "en_US.UTF-8"

VOLUME_FOLDER = "/apple_hdd/hdds/"
MASTER_DISK = VOLUME_FOLDER + "master_hdd.vdi"

PERSONAL_1_DISK = "/media/vms/personal_1_hdd.vdi"

NUM_OF_NODE = 2
NUM_OF_PVC_NODE = 1
OS_IMAGE = "centos/7"

VAGRANTFILE_VERSION = "2"

Vagrant.configure(VAGRANTFILE_VERSION) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.
 
	# vagrant가 모든 vm에 mac addr을 같게 하는 이슈 
	config.vm.base_mac = nil

	config.vm.define "master" do |master|
		master.vm.box = OS_IMAGE
		master.vm.host_name = "master"

		master.vm.network :private_network, ip: "192.168.50.10", netmask: "255.255.255.0", name: "vboxnet0"
		master.vm.network :forwarded_port, guest: 22, host: 2200, id: "ssh", auto_correct: false

		master.vm.provider :virtualbox do |vb|
			vb.cpus = 2
			vb.memory = 4096
			vb.gui = false

			if !File.exist?(MASTER_DISK)
				vb.customize ['createmedium', '--filename', MASTER_DISK, '--size', 10 * 1024, '--variant', 'Standard'] # 10G
			end
			vb.customize ['storageattach', :id, '--storagectl', 'IDE', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', MASTER_DISK]
		end

		master.vbguest.installer_options = { allow_kernel_upgrade: true }

		master.vm.provision :ansible do |ansible|
			ansible.playbook = "k8s-setup/master.yml"
			ansible.extra_vars = {
				node_ip: "192.168.50.10"
			}
		end
		
	end



	# normal node
	(1..NUM_OF_NODE).each do |i|

		node_disk = VOLUME_FOLDER + "node_#{i}_hdd.vdi"

		config.vm.define "node#{i}" do |node|
			node.vm.box = OS_IMAGE
			node.vm.hostname = "node#{i}"

			node.vm.network :private_network, ip: "192.168.50.#{i + 10}", netmask: "255.255.255.0", name: "vboxnet0"
			ssh_port = 2200 + i
			node.vm.network :forwarded_port, guest: 22, host: ssh_port, id: "ssh", auto_correct: false			

			node.vm.provider :virtualbox do |vb|
                        	vb.cpus = 2
                        	vb.memory = 4096
                        	vb.gui = false

                       		if !File.exist?( node_disk )
                                	vb.customize ['createmedium', '--filename', node_disk, '--size', 10 * 1024, '--variant', 'Standard'] # 10G
                        	end

                        	vb.customize ['storageattach', :id, '--storagectl', 'IDE', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', node_disk]
                	end

			node.vbguest.installer_options = { allow_kernel_upgrade: true }

			node.vm.provision :ansible do |ansible|
				ansible.playbook = "k8s-setup/node.yml"
				ansible.extra_vars = {
					node_ip: "192.168.50.#{i + 10}"
				}

			end
		end
	end



	# PVC node
	(1..NUM_OF_PVC_NODE).each do |i|
		config.vm.define "pvc-node#{i}" do |node|
			node.vm.box = OS_IMAGE
			node.vm.hostname = "pvc-node#{i}"
                        node.vm.network :private_network, ip: "192.168.50.#{i + 100}", netmask: "255.255.255.0", name: "vboxnet0"
			node.vm.network :forwarded_port, guest: 22, host: 2301, id: "ssh", auto_correct: false			

                        node.vm.provider :virtualbox do |vb|
                                vb.cpus = 2
                                vb.memory = 4096
                                vb.gui = false
                        end

			node.vm.synced_folder "/apple_hdd/synced", "/synced"
                	node.vbguest.installer_options = { allow_kernel_upgrade: true }

                        node.vm.provision :ansible do |ansible|
                                ansible.playbook = "k8s-setup/node.yml"
                                ansible.extra_vars = {
                                        node_ip: "192.168.50.#{i + 100}"
                                }
                        end
                end
        end


	config.vm.define "personal1" do |p1|
                p1.vm.box = "ubuntu/focal64"
                p1.vm.host_name = "personal1"

		p1.vm.network :public_network
		p1.vm.network :forwarded_port, guest: 22, host: 2401, id: "ssh", auto_correct: false

                p1.vm.provider :virtualbox do |vb|
                        vb.cpus = 4
                        vb.memory = 16384 # 16G
			vb.gui = false
		end

		p1.vm.synced_folder "/media/synced", "/synced"
		#	, owner: "vagrant", group: "vagrant"
		
		p1.vbguest.installer_options = { allow_kernel_upgrade: true }

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
