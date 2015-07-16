template "/etc/mysql/conf.d/slave.cnf" do
  source "slave.cnf.erb"
  owner "root"
  group "root"
  mode "0600"
end

service "mysql" do
  action :restart
end

bash "change master" do
  environment ({
    "MASTER" => node['mysql']['master'],
    "PASSWORD" => node['mysql']['password']
  })
  code <<-E
    echo stop slave | mysql -uroot -p${PASSWORD}
    master=`mysqldump -h${MASTER} -uroot -p${PASSWORD} --master-data=2 -A 2>&1 | head -n 80| grep 'MASTER_LOG_POS' | sed 's/--//' | sed 's/;//'`
    echo "${master}, master_host='${MASTER}', master_user='root', master_password='${PASSWORD}'" | mysql -uroot -p${PASSWORD}
    echo start slave | mysql -uroot -p${PASSWORD}
  E
end
#node['mysql']['master']
#/usr/bin/env mysql  -uroot -pcBfLW5i0 -e 'change master to master_host="85.143.217.223", master_user="root", master_password="3alED4pk", master_log_file="mysql-bin.000001", master_log_pos="107"'
