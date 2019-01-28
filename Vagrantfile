nodes = [
  { :hostname => "msql-01", :ip => "10.0.15.41", :vt_ip => "172.31.1.101", :ram => "1024", :manifest => "mysql_ha.pp" },
  { :hostname => "msql-03", :ip => "10.0.15.43", :vt_ip => "172.31.1.103", :ram => "1024", :manifest => "mysql_ha.pp" },
  { :hostname => "orc-01",  :ip => "10.0.15.44", :vt_ip => "172.31.1.104", :ram => "1024" },
  { :hostname => "cl-01",   :ip => "10.0.15.45", :vt_ip => "172.31.1.105", :ram => "1024" }
]

$ssh_conf = <<SCRIPT
if [[ ! -d /root/.ssh ]]; then
mkdir /root/.ssh
fi
echo 'Host *
StrictHostKeyChecking no' > /root/.ssh/config
chmod 0500 /root/.ssh/config
SCRIPT

$add_to_hosts = <<SCRIPT
echo "172.31.1.101 msql-01.example.com msql-01" >> /etc/hosts
echo "172.31.1.102 msql-02.example.com msql-02" >> /etc/hosts
echo "172.31.1.104 orc-01.example.com orc-01" >> /etc/hosts
echo "172.31.1.105 cl-01.example.com cl-01" >> /etc/hosts
SCRIPT

$puppet_apply = <<SCRIPT
/opt/puppetlabs/bin/puppet apply --verbose --debug --pluginsync --environment dev --environmentpath /etc/puppetlabs/code/environments \
                /etc/puppetlabs/code/environments/dev/manifests
SCRIPT

Vagrant.configure("2") do |config|

    required_plugins = %w( vagrant-hostmanager )
	required_plugins.each do |plugin|
		exec "vagrant plugin install #{plugin};vagrant #{ARGV.join(" ")}" unless Vagrant.has_plugin? plugin || ARGV[0] == 'plugin'
	end


	nodes.each do |node|
		config.vm.define node[:hostname] do |node_config|

			# Image
            node_config.vm.box = "generic/ubuntu1604"
			
			# Forwarding of ssh keys
            node_config.ssh.forward_agent = true
            # Disable NFS sharing
            config.nfs.functional = false

	        # Hostmanager (/etc/hosts)  
	        config.hostmanager.enabled = true
	        config.hostmanager.manage_host = false
	        config.hostmanager.manage_guest = true
	        config.hostmanager.include_offline = true

			# Memory and CPU configuration
            node_config.vm.provider :virtualbox do |vb|
                vb.memory = node[:ram]
                vb.cpus =1
            end

			# Network and hostname configuration
			node_config.vm.network :private_network, :ip => node[:vt_ip]
			node_config.vm.hostname = node[:hostname]
			node_config.hostmanager.aliases = node[:hostname] + '.example.com'

			# Synced folder
			modulename = File.basename(File.dirname(File.expand_path(__FILE__)))
			node_config.vm.synced_folder ".", "/config"
            
			# Provisioners 
			node_config.vm.provision "shell", inline: $ssh_conf
            node_config.vm.provision "shell", inline: "hostnamectl --static set-hostname $1", args: node[:hostname]
            
            # Puppet install
            node_config.vm.provision :shell, :inline => '
            if [ ! -d /opt/puppetlabs ]; then
            wget https://apt.puppetlabs.com/puppet5-release-xenial.deb
            dpkg -i puppet5-release-xenial.deb
            apt-get update
            apt-get -y --allow-downgrades install puppet-agent=5.5.0-1xenial
            fi
            '

            node_config.vm.provision "shell", inline: $add_to_hosts

            if node[:hostname] =~ /msql/
                node_config.vm.provision "shell", path: "./scripts/mysql_install.sh"
                node_config.vm.provision "shell", path: "./scripts/mysql_config.sh"
                node_config.vm.provision "shell", path: "./scripts/mysql_config_root.sh"
                node_config.vm.provision "shell", path: "./scripts/mysql_create_users.sh"
                node_config.vm.provision "shell", path: "./scripts/consul_install_client.sh"
            end

            if node[:hostname] =~ /msql-01/
                node_config.vm.provision "shell", path: "./scripts/mysql_create_db.sh"
            end

            if node[:hostname] =~ /msql-02/
                node_config.vm.provision "shell", path: "./scripts/mysql_config_repl_gtid.sh"
            end

            if node[:hostname] =~ /orc/
                node_config.vm.provision "shell", path: "./scripts/consul_install_master.sh"
                node_config.vm.provision "shell", path: "./scripts/orchestrator_install.sh"
                node_config.vm.provision "shell", path: "./scripts/orchestrator_install_client.sh"
                node_config.vm.provision "shell", path: "./scripts/orchestrator_config.sh"
                node_config.vm.provision "shell", path: "./scripts/orchestrator_discover.sh"
                node_config.vm.provision "shell", path: "./scripts/orchestrator_consul.sh"
                node_config.vm.network "forwarded_port", guest: 3000, host: 3000
                node_config.vm.network "forwarded_port", guest: 8500, host: 3500
            end

            if node[:hostname] =~ /cl-/
                node_config.vm.provision "shell", path: "./scripts/proxysql_install.sh"
                node_config.vm.provision "shell", path: "./scripts/consul_install_client.sh"
                node_config.vm.provision "shell", path: "./scripts/consul_template_install.sh"
            end
		end
	end
end