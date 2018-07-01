# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "pxfs/freebsd-11.1"
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provision :ansible do |ansible|
    ansible.limit = "all"
    ansible.playbook = "ansible/playbook.yml"
    ansible.config_file = "ansible/ansible.cfg"
    ansible.compatibility_mode = "2.0"
  end
end
