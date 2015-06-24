#Ambari Server Specific attributes

default[:ambari][:repo][:url] = "http://public-repo-1.hortonworks.com/ambari/ubuntu12/2.x/updates/2.0.0/ambari.list"
default[:ambari][:hdp][:repo][:url] = "http://public-repo-1.hortonworks.com/HDP/ubuntu12/2.x/updates/2.2.4.2/hdp.list"
default[:ambari][:repo][:dir] = "/etc/apt/sources.list.d"
default[:ambari][:server] = ""
default[:ambari][:database][:username]="ambari"
default[:ambari][:database][:password]="ambari"
default[:ambari][:database][:name]="ambari"
default[:ambari][:view][:instance_name]="Tez1"
default[:ambari][:tar][:url] = "http://public-repo-1.hortonworks.com/ambari/ubuntu12/2.x/updates/2.0.1/ambari-2.0.1-ubuntu12.tar.gz"
default[:ambari][:install_dir] = "/tmp/ambari_server"
default[:ambari][:bins_dir] = "/home/vagrant/chef-bcpc/bins"
default[:ambari][:temp_dir] = "/tmp/new-ambari"
default[:ambari][:deb_path] = "/tmp/ambari_server/ubuntu12/pool/main/a/ambari-server/ambari-server_2.0.1-45_amd64.deb"
default[:ambari][:new_deb_path] = "/tmp/ambari-server-withoutdependencies.deb"
