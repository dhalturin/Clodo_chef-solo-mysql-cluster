package 'mysql-server' do
    action :install
end

template "/tmp/drop_user.sql" do
    source "drop_user.sql.erb"
    owner "root"
    group "root"
    mode "0600"
end

cookbook_file "/tmp/mysql_pass" do
    source "mysql_pass"
    mode "0600"
end

cookbook_file "/etc/init.d/mysqld_skip_grant" do
    source "mysqld_safe"
    mode "0777"
end

service "mysqld_skip_grant" do
    action :start
end

template "/etc/mysql/conf.d/cluster.cnf" do
    source "my.cnf.erb"
    owner "root"
    group "root"
    mode "0600"
end

service "mysql" do
    action :restart
end
