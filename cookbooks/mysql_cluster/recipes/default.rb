puts node[:platform_version]

if node[:platform_version] < "8.0"
    Chef::Application.fatal!("Please use debian jessie")
end

include_recipe "apt"

ruby_block "generate hosts and nodes file" do
    block do
        nodes = ""
        hosts = "127.0.1.1 localhost.localdomain localhost" + $/
        hosts+= "::1 localhost ip6-localhost ip6-loopback" + $/

        Dir[File.absolute_path(File.dirname(__FILE__)) + "/../../../nodes/*.json"].each do |file|
            json = JSON.parse(File.read(file))
            nodes+= "node db" + json['nodeid'] + $/
            hosts+= File.basename(file, '.json') + " db" + json['nodeid'] + $/
        end

        File.open('/etc/hosts', 'w') { |file| file.write hosts }
        File.open('/tmp/nodes', 'w') { |file| file.write nodes }
        File.open('/etc/hostname', 'w') { |file| file.write "db" + node['nodeid'] }
    end
    action :run
end

execute "set hostname" do
    command "hostname db#{node['nodeid']}"
end

include_recipe "mysql_cluster::mysql"
include_recipe "mysql_cluster::corosync"