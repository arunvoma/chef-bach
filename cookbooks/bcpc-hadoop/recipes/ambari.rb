
ambari_repo_url = "http://public-repo-1.hortonworks.com/ambari/ubuntu12/2.x/updates/2.0.0/ambari.list"
hdp_repo_url = "http://public-repo-1.hortonworks.com/HDP/ubuntu12/2.x/updates/2.2.4.2/hdp.list"
repo_dir = "/etc/apt/sources.list.d"
ambari_server_ip="192.168.100.12"
ambari_uri="http://#{ambari_server_ip}:8080/api/v1/views/TEZ/versions/0.5.2.2.2.2.0-151/instances"
instance_name="Tez1"
yarn_timelineserver_url="http://10.0.100.12:8188"
yarn_resourcemanager_url="http://192.168.100.12:8088"


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
end

#Starting multiple services in one block

%w{ambari-server postgresql}.each do |pkg|
service pkg do
  action [:enable, :start]
end
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
command "curl -H \"X-Requested-By:ambari\" -u admin:admin -X POST -d '[{ \"ViewInstanceInfo\" : { \"label\" : \"Tez custom View\", \"properties\" : {\"yarn.timeline-server.url\" : \"#{yarn_timelineserver_url}\", \"yarn.resourcemanager.url\" : \"#{yarn_resourcemanager_url}\" } } } ]' #{ambari_uri}/#{instance_name}"
only_if {"curl -s -H \"X-Requested-By:ambari\" -u admin:admin -X GET #{ambari_uri}/#{instance_name} | grep instance_name | tr -d \", | head -1 | awk -F ':' '{print $2}'|tr -d ' '" != "#{instance_name}"}
notifies :restart, 'service[ambari-server]', :immediately
end
