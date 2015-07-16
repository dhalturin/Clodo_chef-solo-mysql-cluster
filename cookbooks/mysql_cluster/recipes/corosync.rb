apt_repository "sid" do
    uri "http://mirror.yandex.ru/debian"
    distribution "sid"
    components ["main"]
    action :add
end

execute "apt-get update" do
    command "apt-get update"
end

file "/var/lib/mysql/.lock" do
  action :touch
end

#package 'pacemaker' do
#    action :install
#end
#package 'pacemaker-dev' do
#    action :install
#end
bash "install pacemaker" do
    code <<-CMD
        apt-get install -y --yes --force-yes pacemaker; echo $?
        apt-get install -y --yes --force-yes pacemaker-dev; echo $?
    CMD
end

package 'corosync' do
    action :install
end

template "/etc/default/corosync" do
    source "corosync.default.erb"
    owner "root"
    group "root"
    mode "0600"
end

template "/etc/corosync/corosync.conf" do
    source "corosync.conf.erb"
    owner "root"
    group "root"
    mode "0600"
end

ruby_block "generate member list" do
    block do
        members = ""

        Dir[File.absolute_path(File.dirname(__FILE__)) + "/../../../nodes/*.json"].each do |file|
            members+= "member {" + $/ + "memberaddr: " + File.basename(file, '.json') + $/ + "}" + $/
        end

        conf = File.read('/etc/corosync/corosync.conf').gsub(/members/, members)
        File.open('/etc/corosync/corosync.conf', "w") { |file| file.write conf }
    end
    action :run
end

template "/usr/lib/ocf/resource.d/heartbeat/mysql_cluster" do
    source "mmy.resource.erb"
    owner "root"
    group "root"
    mode "0700"
end

template "/tmp/configure" do
    source "crm.configure.erb"
    owner "root"
    group "root"
    mode "0600"
end

ruby_block "set password for param" do
    block do
        pass = File.read('/tmp/mysql_pass')
        conf = File.read('/tmp/configure').gsub(/_auth_key_/, pass)
        File.open('/tmp/configure', "w") { |file| file.write conf }
    end
    action :run
end

service 'pacemaker' do
    action :stop
    ignore_failure true
end

service 'corosync' do
    action :restart
end

service 'pacemaker' do
    action :start
end

bash "import configure" do
    code <<-CMD
        crm configure property stonith-enabled=false
        crm configure load update /tmp/configure
    CMD
end

bash "import nodes" do
    code <<-CMD
        crm configure load update /tmp/nodes
    CMD
end

file "/var/lib/mysql/.lock" do
    action :delete
end