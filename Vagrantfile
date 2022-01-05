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

		master.vm.network :private_network, ip: "192.168.50.10", name: "vboxnet0"
		master.vm.network :forwarded_port, guest: 22, host: 2200, id: "ssh", auto_correct: false

		master.vm.provider :virtualbox do |vb|
			vb.cpus = 2
			vb.memory = 4096
			vb.gui = false

			if !File.exist?(MASTER_DISK)
				vb.customize ['createmedium', '--filename', MASTER_DISK, '--size', 10 * 1024, '--variant', 'Standard'] # 10G
			end
			vb.customize ['storageattach', :id, '--storagectl', 'IDE', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', MASTER_DISK]
			vb.customize ['modifyvm', :id, '--natnet1', "10.0.3/24"]
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

			node.vm.network :private_network, ip: "192.168.50.#{i + 10}", name: "vboxnet0"
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
				vb.customize ['modifyvm', :id, '--natnet1', "10.0.#{i + 10}/24"]
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

                        node.vm.network :private_network, ip: "192.168.50.#{i + 100}", name: "vboxnet0"
			ssh_port = 2300 + i
			node.vm.network :forwarded_port, guest: 22, host: ssh_port, id: "ssh", auto_correct: false			

                        node.vm.provider :virtualbox do |vb|
                                vb.cpus = 2
                                vb.memory = 4096
                                vb.gui = false
				
				vb.customize ['modifyvm', :id, '--natnet1', "10.0.#{i + 100}/24"]
                        end

			node.vm.synced_folder "/apple_hdd/synced", "/synced"
                	node.vbguest.installer_options = { allow_kernel_upgrade: true }

                        node.vm.provision :ansible do |ansible|
                                ansible.playbook = "k8s-setup/node.yml"
                                ansible.extra_vars = {
                                        node_ip: "192.168.50.#{i + 100}"
                                }
                        end

			# trigger.only_on 으로 걸 경우 node1과 pvc-node1에서 모두 수행된다.. 맨아래 주석 참고
			# 해당 VM이 로직상 마지막 k8s node 이므로 생성 후 up trigger를 걸고 label 추가한다.
			if i == NUM_OF_PVC_NODE then
				$script = <<-SCRIPT
        		        chmod +x k8s-setup/node-create-label.sh
		                ./k8s-setup/node-create-label.sh
		                SCRIPT

				node.trigger.after :up,
				info: "Execute create label script.. target node : " + node.vm.hostname,
				ruby: proc { |env, machine| system $script }
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
                        vb.memory = 8192 # 8G
			vb.gui = false
		end

		p1.vm.synced_folder "/media/synced", "/synced"
		#	, owner: "vagrant", group: "vagrant"
		
		p1.vbguest.installer_options = { allow_kernel_upgrade: true }

        end


	#config.trigger.after [ :up ] do |trigger|
	#	trigger_machine_name = "pvc-node" << NUM_OF_PVC_NODE.to_s
	#	# 맨 마지막 노드 생성 이후 실행, 이거 node1이랑 pvc-node1 둘다 동작한다..
	#	trigger.only_on = trigger_machine_name
	#
	#	$script = <<-SCRIPT
	#	chmod +x k8s-setup/node-create-label.sh
	#	./k8s-setup/node-create-label.sh
	#	SCRIPT
	#	
	#	# trigger.info = "Execute create label script.. target node : " + trigger_machine_name
	#	# trigger.run = {inline: $script}
	#end
end
