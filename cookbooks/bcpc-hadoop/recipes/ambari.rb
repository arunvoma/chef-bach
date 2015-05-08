
bash "download_repo" do
code <<EOH
	wget -nv http://public-repo-1.hortonworks.com/ambari/ubuntu12/2.x/updates/2.0.0/ambari.list -O /etc/apt/sources.list.d/ambari.list
	apt-key adv --recv-keys --keyserver
    wget http://public-repo-1.hortonworks.com/HDP/ubuntu12/2.x/updates/2.2.4.2/hdp.list -O /etc/apt/sources.list.d/hdp.list
	apt-get update
	apt-get install ambari-server
	apt-get install tez
EOH
end

%w{ambari-server tez postgresql}.each do |pkg|
  package pkg do
    action :install
  end
end

template "/etc/ambari-server/conf/ambari.properties" do
  source "ambari.properties.erb"
end

execute "setup ambari-server" do
  command "ambari-server setup -s"
  not_if { ::File.exists?("/etc/ambari-server/conf/ambari.properties")}
end

service "ambari-server" do
action [:enable, :start]
end

service "postgresql" do
  action [ :enable, :start ]
end

template "/etc/init.d/hadoop-yarn-timelineserver" do
  source "hdp_hadoop-yarn-timelineserver-initd.erb"
  mode 0655
end

service "hadoop-yarn-timelineserver" do
  action [:enable, :start]
  supports :status => true, :restart => true, :reload => false
  subscribes :restart, "template[/etc/hadoop/conf/hadoop-env.sh]", :delayed
  subscribes :restart, "template[/etc/hadoop/conf/yarn-site.xml]", :delayed
end


execute "create tez view instance" do
  command "curl -H \"X-Requested-By:ambari\" -u admin:admin -X POST -d '[{ \"ViewInstanceInfo\" : { \"label\" : \"Tez custom View\", \"properties\" : {\"yarn.timeline-server.url\" : \"http:/10.0.100.13:8188\", \"yarn.resourcemanager.url\" : \"http://192.168.100.13:8088\" } } } ]' http://192.168.100.13:8080/api/v1/views/TEZ/versions/0.5.2.2.2.2.0-151/instances/Tez1"
  only_if {"curl -s -H \"X-Requested-By:ambari\" -u admin:admin -X GET http://192.168.100.13:8080/api/v1/views/TEZ/versions/0.5.2.2.2.2.0-151/instances/Tez1 | grep instance_name | tr -d \", | head -1 | awk -F ':' '{print $2}'" != "Tez1"}
  notifies :restart, 'service[ambari-server]', :immediately
end
