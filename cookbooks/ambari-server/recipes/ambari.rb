#
# Cookbook Name:: ambari-server
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

#




ambari_repo_url = node[:ambari][:repo][:url]
hdp_repo_url = node[:ambari][:hdp][:repo][:url]
repo_dir = node[:ambari][:repo][:dir]
ambari_server_ip = node[:ambari][:server]
instance_name = node[:ambari][:view][:instance_name]
AMBARIUSER = node[:ambari][:database][:username]
AMBARISERVERFQDN = node[:ambari][:server]
AMBARIDATABASE = node[:ambari][:database][:name]
yarn_timelineserver_url="http://<%= node['ambari']['yarn']['timelineserver']['host']%>:8188"
yarn_resourcemanager_url="http://<%= node['ambari']['yarn']['resourcemgr']['host']%>:8088"
ambari_url= "http://<%= node['ambari']['server']%>:8080/api/v1/views/TEZ/versions/0.5.2.2.2.2.0-151/instances"


make_config('ambari-database-password', secure_password(64))
node.override[:ambari][:database][:password] = get_config('ambari-database-password')
AMBARIPASSWORD = node[:ambari][:database][:password]


%w{ambari-server tez }.each do |pkg|
  package pkg do
    action :install
  end
end

#Code block for Ambari server backend database setup(mysql)
remote_file "#{Chef::Config[:file_cache_path]}/mysql-connector-java-5.1.34.tar.gz" do
  source "#{get_binary_server_url}/mysql-connector-java-5.1.34.tar.gz"
  owner "root"
  group "root"
  mode "755"
  not_if { File.exists?('/usr/share/java/mysql-connector-java-5.1.34-bin.jar') && (Digest::SHA256.hexdigest File.read "/usr/share/java/mysql-connector-java-5.1.34-bin.jar") == "af1e5f28be112c85ec52a82d94e7a8dc02ede57a182dc2f1545f7cec5e808142" }
end

bash "extract-mysql-connector" do
  code "tar xvzf #{Chef::Config[:file_cache_path]}/mysql-connector-java-5.1.34.tar.gz -C /usr/share/java --no-anchored mysql-connector-java-5.1.34-bin.jar --strip-components=1"
  action :run
  group "root"
  user "root"
  not_if { File.exists?('/usr/share/java/mysql-connector-java-5.1.34-bin.jar') && (Digest::SHA256.hexdigest File.read "/usr/share/java/mysql-connector-java-5.1.34-bin.jar") == "af1e5f28be112c85ec52a82d94e7a8dc02ede57a182dc2f1545f7cec5e808142" }
end

link "/usr/share/java/mysql-connector-java.jar" do
  to "/usr/share/java/mysql-connector-java-5.1.34-bin.jar"
end

link "/usr/share/java/mysql.jar" do
  to "/usr/share/java/mysql-connector-java.jar"
end

if ("mysql" == "mysql" ) then
ruby_block "ambari-database-creation" do
      block do

puts %x[ mysql -u#{get_config('mysql-root-user')} -p#{get_config('mysql-root-password')} -e "CREATE DATABASE #{AMBARIDATABASE} CHARACTER SET UTF8;"
mysql -u#{get_config('mysql-root-user')} -p#{get_config('mysql-root-password')} -e "GRANT ALL ON #{AMBARIDATABASE}.* TO '#{AMBARIUSER}'@'%' IDENTIFIED BY '#{AMBARIPASSWORD}';"
mysql -u#{get_config('mysql-root-user')} -p#{get_config('mysql-root-password')} -e "GRANT ALL ON #{AMBARIDATABASE}.* TO '#{AMBARIUSER}'@'localhost' IDENTIFIED BY '#{AMBARIPASSWORD}';"
#mysql -u#{get_config('mysql-root-user')} -p#{get_config('mysql-root-password')} -e "CREATE USER '#{AMBARIUSER}'@'#{AMBARISERVERFQDN}' IDENTIFIED BY '#{AMBARIPASSWORD}';"
#mysql -u#{get_config('mysql-root-user')} -p#{get_config('mysql-root-password')} -e "CREATE USER '#{AMBARIUSER}'@'localhost' IDENTIFIED BY '#{AMBARIPASSWORD}';"
#mysql -u#{get_config('mysql-root-user')} -p#{get_config('mysql-root-password')} -e "CREATE USER '#{AMBARIUSER}'@'%' IDENTIFIED BY '#{AMBARIPASSWORD}';"
mysql -u#{get_config('mysql-root-user')} -p#{get_config('mysql-root-password')} -e "USE #{AMBARIDATABASE};SOURCE /var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql;"
mysql -u#{get_config('mysql-root-user')} -p#{get_config('mysql-root-password')} -e "FLUSH PRIVILEGES;"
]
end
      not_if "mysql -u#{get_config('mysql-root-user')} -p#{get_config('mysql-root-password')} -e \"SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = \'#{AMBARIDATABASE}\'\" | grep #{AMBARIDATABASE} "
   end
end

execute "setup ambari-server" do
  command "ambari-server setup -s"
end

template "/etc/ambari-server/conf/ambari.properties" do
  source "ambari.properties.erb"
end

#Starting multiple services in one block

%w{ambari-server }.each do |pkg|
service pkg do
  action [:enable, :start]
end
end


