

default["tomcat-openam"]["user"] = "vagrant"
default["tomcat-openam"]["super-user"] = "root"
default["tomcat-openam"]["group"] = "vagrant"
default["tomcat-openam"]["mode"] = "0755"
default["tomcat-openam"]["checksum"] = "08da002l"

#directory paths
default["tomcat-openam"]["home"] = "/home/vagrant"
default["tomcat-openam"]["tomcat-home"] = "/home/vagrant/tomcat"
default["tomcat-openam"]["dir-path"]["webapps-war"] = "/var/lib/tomcat6/webapps/openam.war"
default["tomcat-openam"]["dir-path"]["tmp"] = "/home/vagrant/tmp"
default["tomcat-openam"]["dir-path"]["openam"] = "/home/vagrant/openam"
default["tomcat-openam"]["dir-path"]["tmp-openam"] = "/home/vagrant/tmp/openam"
default["tomcat-openam"]["dir-path"][".openssocfg"] = "/home/vagrant/.openssocfg"

#Source files
default["tomcat-openam"]["source"]["tomcat"] = "https://s3-ap-southeast-1.amazonaws.com/megam/chef/tomcat/tomcat.tar.gz"
default["tomcat-openam"]["source"]["openam-war"] ="http://download.forgerock.org/downloads/enterprise/openam/openam10/10.1.0/openam_10.1.0.war"
default["tomcat-openam"]["source"]["ssoconfig-zip"] = "https://s3-ap-southeast-1.amazonaws.com/megam/chef/openam/ssoConfiguratorTools.zip"
default["tomcat-openam"]["source"]["opendj-zip"] = "https://s3-ap-southeast-1.amazonaws.com/megam/chef/opendj/opendj.zip"

#Remote files location
default["tomcat-openam"]["remote-location"]["tomcat-tar"] = "/home/vagrant/tmp/tomcat.tar.gz"
default["tomcat-openam"]["remote-location"]["openam-tar"] = "/var/lib/tomcat6/webapps/openam.war"
default["tomcat-openam"]["remote-location"]["ssoConfigurator"] = "/home/vagrant/tmp/openam/ssoConfiguratorTools.zip"
default["tomcat-openam"]["remote-location"]["opendj-zip"] = "/home/vagrant/tmp/opendj.zip"
default["tomcat-openam"]["remote-location"]["tomcat-init"] = "/etc/init.d/tomcat"
default["tomcat-openam"]["remote-location"]["openam-config"] = "/home/vagrant/tmp/openam_cli_config.properties"

#Template files
default["tomcat-openam"]["template"]["tomcat_init"] = 'tomcat_init.sh.erb'
default["tomcat-openam"]["template"]["openam-full-config"] = 'full_stack_cli_config.properties.erb'
default["tomcat-openam"]["template"]["openam-config"] = 'openam_cli_config.properties.erb'

#shell commands
default["tomcat-openam"]["cmd"] ["tomcat-unzip"] = "gunzip -c /home/vagrant/tmp/tomcat.tar.gz | tar xvf -"
default["tomcat-openam"]["cmd"] ["tomcat-update"] = "sudo update-rc.d tomcat defaults"
default["tomcat-openam"]["cmd"] ["tomcat-start"] = "service tomcat start"
default["tomcat-openam"]["cmd"] ["tomcat-restart"] = "service tomcat restart"

#Arguement's values for the OpenDJ Configuration Command
default["tomcat-openam"]["opendj"]["arg-val"]["baseDN"] = "dc=example,dc=com"
default["tomcat-openam"]["opendj"]["arg-val"]["rootUserDN"] = "cn=Directory Manager"
default["tomcat-openam"]["opendj"]["arg-val"]["rootUserPassword"] = "secret12"
default["tomcat-openam"]["opendj"]["arg-val"]["ldapPort"] = "1389"

#Java Options
default["tomcat-openam"]["java-options"] = "-Xms256m -Xmx1024m"

#Configuration Commands
default["tomcat-openam"]["cmd"]["config"]["opendj"] = "./opendj/setup --cli --baseDN  #{node["tomcat-openam"]["opendj"]["arg-val"]["baseDN"]}  --rootUserDN  '#{node["tomcat-openam"]["opendj"]["arg-val"]["rootUserDN"]}' --rootUserPassword  #{node["tomcat-openam"]["opendj"]["arg-val"]["rootUserPassword"]} -h `hostname` --ldapPort #{node["tomcat-openam"]["opendj"]["arg-val"]["ldapPort"]} --no-prompt"

default["tomcat-openam"]["cmd"]["config-sso"] = "java -jar #{node["tomcat-openam"]["java-options"]} /home/vagrant/tmp/openam/configurator.jar -f /home/vagrant/tmp/openam_cli_config.properties > /home/vagrant/tmp/openam.out"

#AWS public DNS
default["tomcat-openam"]["dns"] = "localhost"   #"#{node[:ec2][:public_hostname]}"
default["tomcat-openam"]["instance_id"] = "12132131" #"#{node['ec2']['instance_id']}"

#OpenAM_CLI_Config properties
default["tomcat-openam"]["cfg"]["server-url"] = "http://#{node["tomcat-openam"]["dns"]}:8080"
default["tomcat-openam"]["cfg"]["deployment-uri"] = "/openam"
default["tomcat-openam"]["cfg"]["base-dir"] = "#{node["tomcat-openam"]["home"]}/openam"
default["tomcat-openam"]["cfg"]["locale"] = "en_US"
default["tomcat-openam"]["cfg"]["platform-locale"] = "en_US"
default["tomcat-openam"]["cfg"]["admin-pwd"] = "adminp3me"
default["tomcat-openam"]["cfg"]["amldapuserpasswd"] = "adminl3me"
default["tomcat-openam"]["cfg"]["cookie-domain"] = ".#{node["tomcat-openam"]["dns"]}"
default["tomcat-openam"]["cfg"]["data-store"] = "embedded"
default["tomcat-openam"]["cfg"]["directory"]["ssl"] = "SIMPLE"
default["tomcat-openam"]["cfg"]["directory"]["server"] = "#{node["tomcat-openam"]["dns"]}"
default["tomcat-openam"]["cfg"]["directory"]["port"] = "50389"
default["tomcat-openam"]["cfg"]["directory"]["admin-port"] = "5444"
default["tomcat-openam"]["cfg"]["directory"]["jmx-port"] = "5689"
default["tomcat-openam"]["cfg"]["root-suffix"] = "o=openam"
default["tomcat-openam"]["cfg"]["ds-dirmgrdn"] = "cn=Directory Manager"
default["tomcat-openam"]["cfg"]["ds-dirmgrpasswd"] = "emdstor3me"
default["tomcat-openam"]["cfg"]["user-store"]["type"] = "LDAPv3ForOpenDS"
default["tomcat-openam"]["cfg"]["user-store"]["ssl"] = "SIMPLE"
default["tomcat-openam"]["cfg"]["user-store"]["host"] = "ec2-54-251-5-170.ap-southeast-1.compute.amazonaws.com" #opendj DNS
default["tomcat-openam"]["cfg"]["user-store"]["port"] = "1389"
default["tomcat-openam"]["cfg"]["user-store"]["suffix"] = "dc=example,dc=com"
default["tomcat-openam"]["cfg"]["user-store"]["mgrdn"] = "cn=Directory Manager"
default["tomcat-openam"]["cfg"]["user-store"]["passwd"] = "secret12"

