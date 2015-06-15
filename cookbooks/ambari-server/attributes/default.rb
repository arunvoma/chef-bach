


default[:ambari][:repo][:url] = "http://public-repo-1.hortonworks.com/ambari/ubuntu12/2.x/updates/2.0.0/ambari.list"
default[:ambari][:hdp][:repo][:url] = "http://public-repo-1.hortonworks.com/HDP/ubuntu12/2.x/updates/2.2.4.2/hdp.list"
default[:ambari][:repo][:dir] = "/etc/apt/sources.list.d"
default[:ambari][:yarn][:timelineserver][:host]="f-bcpc-vm2.example.com"
default[:ambari][:yarn][:resourcemgr][:host]="bcpc-vm2.example.com"
default[:ambari][:yarn][:timelineserver][:url] = "http://<%= node['ambari']['yarn']['timelineserver_host']%>:8188"
default[:ambari][:yarn][:resourcemanager][:url] = "http://<%= node['ambari']['yarn']['resourcemgr_host']%>:8088"
default[:ambari][:server] = "bcpc-vm2.example.com"
default[:ambari][:database][:username]="ambari"
default[:ambari][:database][:password]="ambari"
default[:ambari][:database][:name]="ambari"
default[:ambari][:view][:instance_name]="Tez1"

