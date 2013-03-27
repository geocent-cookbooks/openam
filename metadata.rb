maintainer       "Geocent"
maintainer_email "clarence.davis@geocent.com, tyler.sanders@geocent.com"
license          "All rights reserved"
description      "Installs/Configures OpenAM Access Management Platform"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"


%w{ java }.each do |cb|
  depends cb
end

%w{ debian ubuntu }.each do |os|
  supports os
end

recipe "tomcat-openam::full_stack", "Installs and configures Tomcat, OpenDJ and OpenAM In a single instance"
recipe "tomcat-openam::default", "Installs Tomcat and OpenAM. But Configures only tomcat"
recipe "tomcat-openam::configure", "Configures OpenAM" #It needs a dns of an instance which is running opendj

