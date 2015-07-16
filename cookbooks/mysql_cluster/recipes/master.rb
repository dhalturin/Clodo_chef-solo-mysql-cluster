template "/etc/mysql/conf.d/master.cnf" do
  source "master.cnf.erb"
  owner "root"
  group "root"
  mode "0600"
end

service "mysql" do
  action :restart
end
