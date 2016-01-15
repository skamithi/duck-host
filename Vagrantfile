# -*- mode: ruby -*-
# vi: set ft=ruby :

switch_box = 'cumulus-vx-2.5.5'
server_box = 'centos7'
wbenchvm_box = 'trusty64'
ext_rtr_box = 'trusty64'

wbenchvm_memory = 4096
switch_memory = 512
server_memory = 8192
ext_rtr_memory = 256

wbench_hostlist = [:test_ext_rtr, :spine1, :leaf1, :leaf2,
                  :leaf3, :leaf4, :ext_rtr1, :ext_rtr2,
                  :server1, :server2, :server3, :server4]
last_ip_octet = 100
last_mac_octet = 11
wbench_hosts = { :wbench_hosts => {} }

wbench_hostlist.each do |hostentry|
  wbench_hosts[:wbench_hosts][hostentry] = {
    :ip => '192.168.0.' + last_ip_octet.to_s,
    :mac => '12:11:22:33:44:' + last_mac_octet.to_s
  }
  last_mac_octet += 1
  last_ip_octet += 1
end

Vagrant.configure("2") do |config|

    config.vm.synced_folder '.', '/vagrant', :disabled => true

    config.vm.provider :libvirt do |domain|
        domain.nic_adapter_count = 20
    end


    config.vm.define :wbenchvm do |node|
      node.vm.provider :libvirt do |domain|
        domain.memory = wbenchvm_memory
      end
      node.vm.box = wbenchvm_box
      node.vm.hostname = 'openstack-mgmtvm'
      # disabling sync folder support on all VMs
      node.vm.synced_folder '.', '/vagrant', :disabled => true

      # eth1
      node.vm.network :private_network,
        :ip => '192.168.0.1/24',
        :libvirt__forward_mode => 'veryisolated',
        :libvirt__dhcp_enabled => false,
        :libvirt__network_name => 'switch_mgmt'
      node.vm.provision :ansible do |ansible|
        ansible.playbook = 'ccw-wbenchvm/site.yml'
        ansible.extra_vars = wbench_hosts
        ansible.force_remote_user = false
      end
      node.vm.provision :ansible do |ansible|
        ansible.playbook = 'playbooks/wbenchvm_extra.yml'
      end
    end

  config.vm.define "test_ext_rtr" do |test_ext_rtr|
      test_ext_rtr.vm.hostname = "test-ext-rtr"
      test_ext_rtr.vm.box = switch_box

      test_ext_rtr.vm.provider :libvirt do |domain|
        domain.memory = switch_memory
      end
      # ext_rtr1:swp49 -- test_ext_rtr:swp1
      test_ext_rtr.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '17010',
        :libvirt__tunnel_local_port => '18010'
      # ext_rtr2:swp49 -- test_ext_rtr:swp2
      test_ext_rtr.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '17015',
        :libvirt__tunnel_local_port => '18015'

  end

    config.vm.define "spine1" do |spine1|
      spine1.vm.hostname = "spine1"
      spine1.vm.box = switch_box

      spine1.vm.provider :libvirt do |domain|
        domain.memory = switch_memory
      end

      # eth0 (after deleting vagrant interface)
      spine1.vm.network :private_network,
        :auto_config => false,
        :libvirt__forward_mode => 'veryisolated',
        :libvirt__dhcp_enabled => false,
        :libvirt__network_name => 'switch_mgmt',
        :mac => wbench_hosts[:wbench_hosts][:spine1][:mac]

      # spine1:swp1 -- leaf1:swp49
      spine1.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '18007',
        :libvirt__tunnel_local_port => '17007'
      # spine1:swp2 -- leaf2:swp49
      spine1.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '18013',
        :libvirt__tunnel_local_port => '17013'
      # spine1:swp3 -- leaf3:swp49
      spine1.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '18003',
        :libvirt__tunnel_local_port => '17003'
      # spine1:swp4 -- leaf4:swp49
      spine1.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '18019',
        :libvirt__tunnel_local_port => '17019'

      spine1.vm.provision :ansible do |ansible|
        ansible.playbook = 'playbooks/bootstrap_switch.yml'
      end

    end

    config.vm.define "leaf1" do |leaf1|
      leaf1.vm.hostname = "leaf1"
      leaf1.vm.box = switch_box

      leaf1.vm.provider :libvirt do |domain|
        domain.memory = switch_memory
      end

      # eth0 (after deleting vagrant interface)
      leaf1.vm.network :private_network,
        :auto_config => false,
        :libvirt__forward_mode => 'veryisolated',
        :libvirt__dhcp_enabled => false,
        :libvirt__network_name => 'switch_mgmt',
        :mac => wbench_hosts[:wbench_hosts][:leaf1][:mac]

      # leaf1:swp1 -- leaf2:swp1
      leaf1.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '18021',
        :libvirt__tunnel_local_port => '17021'
      # leaf1:swp2 -- leaf2:swp2
      leaf1.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '18005',
        :libvirt__tunnel_local_port => '17005'
      # leaf1:swp3 -- server1:eth1
      leaf1.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '18001',
        :libvirt__tunnel_local_port => '17001'
      # leaf1:swp4 -- server2:eth1
      leaf1.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '18009',
        :libvirt__tunnel_local_port => '17009'
      # spine1:swp1 -- leaf1:swp49
      leaf1.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '17007',
        :libvirt__tunnel_local_port => '18007'

      leaf1.vm.provision :ansible do |ansible|
        ansible.playbook = 'playbooks/bootstrap_switch.yml'
      end

    end
    config.vm.define "leaf2" do |leaf2|
      leaf2.vm.hostname = "leaf2"
      leaf2.vm.box = switch_box

      leaf2.vm.provider :libvirt do |domain|
        domain.memory = switch_memory
      end

      # eth0 (after deleting vagrant interface)
      leaf2.vm.network :private_network,
        :auto_config => false,
        :libvirt__forward_mode => 'veryisolated',
        :libvirt__dhcp_enabled => false,
        :libvirt__network_name => 'switch_mgmt',
        :mac => wbench_hosts[:wbench_hosts][:leaf2][:mac]

      # leaf1:swp1 -- leaf2:swp1
      leaf2.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '17021',
        :libvirt__tunnel_local_port => '18021'
      # leaf1:swp2 -- leaf2:swp2
      leaf2.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '17005',
        :libvirt__tunnel_local_port => '18005'
      # leaf2:swp3 -- server1:eth2
      leaf2.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '18016',
        :libvirt__tunnel_local_port => '17016'
      # leaf2:swp4 -- server2:eth2
      leaf2.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '18008',
        :libvirt__tunnel_local_port => '17008'
      # spine1:swp2 -- leaf2:swp49
      leaf2.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '17013',
        :libvirt__tunnel_local_port => '18013'


      leaf2.vm.provision :ansible do |ansible|
        ansible.playbook = 'playbooks/bootstrap_switch.yml'
      end

    end

    config.vm.define "leaf3" do |leaf3|
      leaf3.vm.hostname = "leaf3"
      leaf3.vm.box = switch_box

      leaf3.vm.provider :libvirt do |domain|
        domain.memory = switch_memory
      end

      # eth0 (after deleting vagrant interface)
      leaf3.vm.network :private_network,
        :auto_config => false,
        :libvirt__forward_mode => 'veryisolated',
        :libvirt__dhcp_enabled => false,
        :libvirt__network_name => 'switch_mgmt',
        :mac => wbench_hosts[:wbench_hosts][:leaf3][:mac]

      # leaf3:swp1 -- leaf4:swp1
      leaf3.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '18000',
        :libvirt__tunnel_local_port => '17000'
      # leaf3:swp2 -- leaf4:swp2
      leaf3.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '18017',
        :libvirt__tunnel_local_port => '17017'
      # leaf3:swp3 -- server3:eth1
      leaf3.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '18004',
        :libvirt__tunnel_local_port => '17004'
      # leaf3:swp4 -- server4:eth1
      leaf3.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '18011',
        :libvirt__tunnel_local_port => '17011'
      # spine1:swp3 -- leaf3:swp49
      leaf3.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '17003',
        :libvirt__tunnel_local_port => '18003'

      leaf3.vm.provision :ansible do |ansible|
        ansible.playbook = 'playbooks/bootstrap_switch.yml'
      end

    end

    config.vm.define "leaf4" do |leaf4|
      leaf4.vm.hostname = "leaf4"
      leaf4.vm.box = switch_box

      leaf4.vm.provider :libvirt do |domain|
        domain.memory = switch_memory
      end


      # eth0 (after deleting vagrant interface)
      leaf4.vm.network :private_network,
        :auto_config => false,
        :libvirt__forward_mode => 'veryisolated',
        :libvirt__dhcp_enabled => false,
        :libvirt__network_name => 'switch_mgmt',
        :mac => wbench_hosts[:wbench_hosts][:leaf4][:mac]


      # leaf3:swp1 -- leaf4:swp1
      leaf4.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '17000',
        :libvirt__tunnel_local_port => '18000'
      # leaf3:swp2 -- leaf4:swp2
      leaf4.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '17017',
        :libvirt__tunnel_local_port => '18017'
      # leaf4:swp3 -- server3:eth2
      leaf4.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '18012',
        :libvirt__tunnel_local_port => '17012'
      # leaf4:swp4 -- server4:eth2
      leaf4.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '18002',
        :libvirt__tunnel_local_port => '17002'
      # spine1:swp4 -- leaf4:swp49
      leaf4.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '17019',
        :libvirt__tunnel_local_port => '18019'

      leaf4.vm.provision :ansible do |ansible|
        ansible.playbook = 'playbooks/bootstrap_switch.yml'
      end

    end



  config.vm.define "ext_rtr1" do |ext_rtr1|
      ext_rtr1.vm.hostname = "ext-rtr1"
      ext_rtr1.vm.box = switch_box

      ext_rtr1.vm.provider :libvirt do |domain|
        domain.memory = switch_memory
      end
      # eth0 (after deleting vagrant interface)
      ext_rtr1.vm.network :private_network,
        :auto_config => false,
        :libvirt__forward_mode => 'veryisolated',
        :libvirt__dhcp_enabled => false,
        :libvirt__network_name => 'switch_mgmt',
        :mac => wbench_hosts[:wbench_hosts][:ext_rtr1][:mac]

      # ext_rtr1:swp1 -- server3:eth3
      ext_rtr1.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '18020',
        :libvirt__tunnel_local_port => '17020'
      # ext_rtr1:swp2 -- server4:eth3
      ext_rtr1.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '18006',
        :libvirt__tunnel_local_port => '17006'
      # ext_rtr1:swp49 -- test_ext_rtr:swp1
      ext_rtr1.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '18010',
        :libvirt__tunnel_local_port => '17010'

      ext_rtr1.vm.provision :ansible do |ansible|
        ansible.playbook = 'playbooks/bootstrap_switch.yml'
      end
  end

  config.vm.define "ext_rtr2" do |ext_rtr2|
      ext_rtr2.vm.hostname = "ext-rtr2"
      ext_rtr2.vm.box = switch_box

      ext_rtr2.vm.provider :libvirt do |domain|
        domain.memory = switch_memory
      end

      # eth0 (after deleting vagrant interface)
      ext_rtr2.vm.network :private_network,
        :auto_config => false,
        :libvirt__forward_mode => 'veryisolated',
        :libvirt__dhcp_enabled => false,
        :libvirt__network_name => 'switch_mgmt',
        :mac => wbench_hosts[:wbench_hosts][:ext_rtr2][:mac]

      # ext_rtr2:swp1 -- server3:eth4
      ext_rtr2.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '18018',
        :libvirt__tunnel_local_port => '17018'
      # ext_rtr2:swp2 -- server4:eth4
      ext_rtr2.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '18014',
        :libvirt__tunnel_local_port => '17014'
      # ext_rtr2:swp49 -- test_ext_rtr:swp2
      ext_rtr2.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '18015',
        :libvirt__tunnel_local_port => '17015'

      ext_rtr2.vm.provision :ansible do |ansible|
        ansible.playbook = 'playbooks/bootstrap_switch.yml'
      end
  end


    config.vm.define "server1" do |server1|
      server1.vm.hostname = "server1"
      server1.vm.box = server_box


      server1.vm.provider :libvirt do |domain|
        domain.memory = server_memory
      end

      # eth0 (after deleting vagrant interface)
      server1.vm.network :private_network,
        :auto_config => false,
        :libvirt__forward_mode => 'veryisolated',
        :libvirt__dhcp_enabled => false,
        :libvirt__network_name => 'switch_mgmt',
        :mac => wbench_hosts[:wbench_hosts][:server1][:mac]

      # leaf1:swp3 -- server1:eth1
      server1.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '17001',
        :libvirt__tunnel_local_port => '18001'
      # leaf2:swp3 -- server1:eth2
      server1.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '17016',
        :libvirt__tunnel_local_port => '18016'

      server1.vm.provision :ansible do |ansible|
        ansible.playbook = 'playbooks/bootstrap_server.yml'
      end

    end

    config.vm.define "server2" do |server2|
      server2.vm.hostname = "server2"
      server2.vm.box = server_box

      server2.vm.provider :libvirt do |domain|
        domain.memory = server_memory
      end

      server2.vm.provision :ansible do |ansible|
        ansible.playbook = 'playbooks/bootstrap_server.yml'
      end
      # eth0 (after deleting vagrant interface)
      server2.vm.network :private_network,
        :auto_config => false,
        :libvirt__forward_mode => 'veryisolated',
        :libvirt__dhcp_enabled => false,
        :libvirt__network_name => 'switch_mgmt',
        :mac => wbench_hosts[:wbench_hosts][:server2][:mac]

      # leaf1:swp4 -- server2:eth1
      server2.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '17009',
        :libvirt__tunnel_local_port => '18009'
      # leaf2:swp4 -- server2:eth2
      server2.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '17008',
        :libvirt__tunnel_local_port => '18008'
    end

    config.vm.define "server3" do |server3|
      server3.vm.hostname = "server3"
      server3.vm.box = server_box

      server3.vm.provider :libvirt do |domain|
        domain.memory = server_memory
      end

      server3.vm.provision :ansible do |ansible|
        ansible.playbook = 'playbooks/bootstrap_server.yml'
      end

      # eth0 (after deleting vagrant interface)
      server3.vm.network :private_network,
        :auto_config => false,
        :libvirt__forward_mode => 'veryisolated',
        :libvirt__dhcp_enabled => false,
        :libvirt__network_name => 'switch_mgmt',
        :mac => wbench_hosts[:wbench_hosts][:server3][:mac]

      # leaf3:swp3 -- server3:eth1
      server3.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '17004',
        :libvirt__tunnel_local_port => '18004'
      # leaf4:swp3 -- server3:eth2
      server3.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '17012',
        :libvirt__tunnel_local_port => '18012'
      # ext_rtr1:swp1 -- server3:eth3
      server3.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '17020',
        :libvirt__tunnel_local_port => '18020'
      # ext_rtr2:swp1 -- server3:eth4
      server3.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '17018',
        :libvirt__tunnel_local_port => '18018'
    end

    config.vm.define "server4" do |server4|
      server4.vm.hostname = "server4"
      server4.vm.box = server_box


      server4.vm.provider :libvirt do |domain|
        domain.memory = server_memory
      end


      server4.vm.provision :ansible do |ansible|
        ansible.playbook = 'playbooks/bootstrap_server.yml'
      end

      # eth0 (after deleting vagrant interface)
      server4.vm.network :private_network,
        :auto_config => false,
        :libvirt__forward_mode => 'veryisolated',
        :libvirt__dhcp_enabled => false,
        :libvirt__network_name => 'switch_mgmt',
        :mac => wbench_hosts[:wbench_hosts][:server4][:mac]

      # leaf3:swp4 -- server4:eth1
      server4.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '17011',
        :libvirt__tunnel_local_port => '18011'
      # leaf4:swp4 -- server4:eth2
      server4.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '17002',
        :libvirt__tunnel_local_port => '18002'
      # ext_rtr1:swp2 -- server4:eth3
      server4.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '17006',
        :libvirt__tunnel_local_port => '18006'
      # ext_rtr2:swp2 -- server4:eth4
      server4.vm.network :private_network,
        :libvirt__tunnel_type => 'udp',
        :libvirt__tunnel_port => '17014',
        :libvirt__tunnel_local_port => '18014'

    end

end
