#
# Cookbook Name:: OpenAM
# Recipe:: default
#
# Copyright 2012, Geocent
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apache2"
include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_http"

case node[:platform]
when "debian", "ubuntu"
  

remote_file node["tomcat-openam"]["remote-location"]["openam-tar"] do
  source node["tomcat-openam"]["source"]["openam-war"]
  mode node["tomcat-openam"]["mode"]
  owner node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  checksum node["tomcat-openam"]["checksum"] 
end

directory node["tomcat-openam"]["dir-path"]["tmp"] do
  owner node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  mode node["tomcat-openam"]["mode"]
  action :create
end

directory node["tomcat-openam"]["dir-path"]["openam"] do
  owner node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  mode node["tomcat-openam"]["mode"]
  action :create
end

directory node["tomcat-openam"]["dir-path"]["tmp-openam"] do
  owner node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  mode node["tomcat-openam"]["mode"]
  action :create
end


remote_file node["tomcat-openam"]["remote-location"]["ssoConfigurator"] do
  source node["tomcat-openam"]["source"]["ssoconfig-zip"]
  mode node["tomcat-openam"]["mode"]
  owner node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  checksum node["tomcat-openam"]["checksum"] 
end

package 'zip'
execute "unzip openam ssoconfigurator" do
  command <<CMD
umask 022
unzip -u -o "/home/vagrant/tmp/openam/ssoConfiguratorTools.zip"
CMD
  cwd node["tomcat-openam"]["dir-path"]["tmp-openam"]
  user node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  action :run
  not_if { ::File.exist?("/home/vagrant/tmp/openam/configurator.jar") }
end

#DAV

template node["tomcat-openam"]["remote-location"]["openam-config"] do
  source node["tomcat-openam"]["template"]["openam-config"]
  owner node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  mode node["tomcat-openam"]["mode"]
 end

directory node["tomcat-openam"]["dir-path"][".openssocfg"] do
  owner node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  mode node["tomcat-openam"]["mode"]
  action :create
end

directory node["tomcat-openam"]["dir-path"]["openam"] do
  owner node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  mode node["tomcat-openam"]["mode"]
  action :create
end

execute "configuring-openam" do
  cwd node["tomcat-openam"]["dir-path"][".openssocfg"]
  user node["tomcat-openam"]["user"]
  group node["tomcat-openam"]["user"]
  command node["tomcat-openam"]["cmd"]["config-sso"]
   action :run
end

end




