# uncomment connector to port 8009 in /etc/tomcat6/server.xml

sudo a2enmod proxy_ajp
# add proxypass rules to /etc/apache2/sites-enabled/000-default
sudo sed -ie "/<\/VirtualHost>/i\<Proxy *>    \n  Allow from 75.101.153.231    \n</Proxy>    \nProxyPass / ajp://75.101.153.231:8009/ \nProxyPassReverse / ajp://75.101.153.231:8009/    \n" /etc/apache2/sites-enabled/000-default
sudo service apache2 restart
