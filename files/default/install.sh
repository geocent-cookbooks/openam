#!/bin/sh

# constants
p="\n[OpenAM Install] "
username="amadmin"
password="adminadmin"
localip="127.0.0.1"

echo "$p Away we go..."

# Install opengeo-suite
if grep opengeo /etc/apt/sources.list
then
  echo "$p opengeo-suite is already installed"
else
  echo "$p Installing open-geo suite"

  wget -qO- http://apt.opengeo.org/gpg.key | sudo apt-key add -
  sudo sh -c "echo \"deb http://apt.opengeo.org/ubuntu lucid main\" >> /etc/apt/sources.list"
  sudo apt-get update

  sudo apt-get install -y -q debconf-utils

  echo "opengeo_geoserver opengeo_geoserver/proxyurl string 75.101.152.231
   opengeo_geoserver opengeo_geoserver/username string admin
   opengeo_geoserver opengeo_geoserver/password password geoserver
   opengeo_geoserver opengeo_geoserver/password_confirm password geoserver
   opengeo_postgis opengeo_postgis/configure_postgis boolean true" | sudo debconf-set-selections
  export DEBIAN_FRONTEND=noninteractive

  sudo apt-get install -y opengeo-suite
fi

# Prevent tomcat6 permgen errors
## TODO: This is different than what's on demo.geocent.com:
## JAVA_OPTS='-Djava.awt.headless=true -Xmx1024m -Xms1024M -XX:MaxPermSize=256m -XX:CompileCommand=exclude,net/sf/saxon/event/ReceivingContentHandler.startElement'
if grep -q 'MaxPermSize' /etc/default/tomcat6
then
  echo "$p PermSize already set in tomcat6 startup options"
else
  echo "$p Set permsize in tomcat6 startup options"
  sudo sed -ie '/^JAVA_OPTS=/s/"$/ -Djava.awt.headless=true -Xms1024m -Xmx1024m -Xrs -XX:PerfDataSamplingInterval=500 -XX:MaxPermSize=256m"/' /etc/default/tomcat6
fi

sudo sed -ie 'N;N;N;s/ *<!-- *\n* *\(<Connector.*port="8009".*>\) *\n* *-->/    \1/g' /etc/tomcat6/server.xml

# Create build user
if id $username > /dev/null
then
	echo "$p User $username already exists"
else
	echo "$p Creating user $username"
	# Encrypt the password so we can pass it to useradd -p
	pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
	useradd -m -p $pass -s /bin/bash $username
	if [ $? -eq 0 ]; then
		echo "User $username has been added to system"
	else
		"Failed to add user $username"
		exit 1
	fi
fi

# give build user sudo access
if sudo grep -q $username /etc/sudoers
then
  echo "$p $username already has sudo rights"
else
  echo "$p give $username sudo rights"
  echo "$username   ALL=(ALL)       ALL" | sudo tee -a /etc/sudoers > /dev/null
fi

# pull most recent source
if test -s /home/$username/OpenCOP/.git/
then
  echo "$p Pulling latest OpenCOP source code from github"
  sudo su $username -c 'cd ~/OpenCOP; git pull'
else
  echo "$p Downloading OpenCOP source code from github"
  sudo su $username -c 'cd; git clone git://github.com/OpenCOP/OpenCOP.git'
fi

# Run the local_deploy script
## TODO: Or run this as tomcat6 instead (if that works)
echo "$p Running local_deploy script"
su $username -c 'cd ~/OpenCOP; sh ./local_deploy'

# Kinda hacky: The war copy will fail in local_deploy because the user doesn't have permissions to the tomcat directory
# So copy it here
cp /home/$username/OpenCOP/build/opencop.war /var/lib/tomcat6/webapps

sudo service tomcat6 restart

# TODO: Will need to move the icons folder from OC1 to OC2 and do this again
# move icons folder
#echo "$p move icons folder from source to tomcat"
#sudo cp -ur /home/$username/OpenCOP/opencop-icons/ /var/lib/tomcat6/webapps/


# Install curl to use for REST calls to geoserver
echo "$p Installing curl"
apt-get install curl

sudo service tomcat6 restart

# Wait for Geoserver to come up
geoserver_up="false"
echo -n "$p Waiting for Geoserver to come up. This may take a minute or two..."

while [ $geoserver_up != "true" ]
do
	response=`curl -s -XGET -u admin:geoserver -H 'Accept: text/xml' http://$localip/geoserver/rest/workspaces/`

	greppage=`echo $response | grep workspace`

	if [ "x" != "x$greppage" ]; then
		echo "Done."
		geoserver_up="true"
	else
		echo -n "."
		sleep 3
	fi
done

# Add the opencop workspace/namespace
## TODO: Check the return values from these calls
echo -n "$p Adding opencop workspace..."
response=`curl -s -u admin:geoserver --write-out %{http_code} -XPOST -H 'Content-type: text/xml' -d "<namespace><uri>http://$localip</uri><prefix>opencop</prefix></namespace>" http://$localip/geoserver/rest/namespaces`
if [ "$response" = "201" ]; then
    echo "Success."
else
    echo "Failed. $response"
    exit 1
fi

echo -n "$p Adding the opencop data store..."
## TODO: Not all the params are specified here(spaces in, for example, "max connections", hose up the xml). Doesn't appear they need to be, but...
response=`curl -s -u admin:geoserver --write-out %{http_code} -XPOST -H 'Content-type: text/xml' -d "<dataStore><name>opencop</name><connectionParameters><host>$localip</host><port>5432</port><database>opencop</database><user>opencop</user><dbtype>postgis</dbtype><passwd>57levelsofeoc</passwd></connectionParameters></dataStore>" http://$localip/geoserver/rest/workspaces/opencop/datastores`
if [ "$response" = "201" ]; then
    echo "Success."
else
    echo "Failed. $response"
    exit 1
fi

for layername in "baselayer" "config" "icon" "iconmaster" "iconstolayers" "layer" "layergroup"
do
echo -n "$p Publishing $layername layer... "
response=`curl -s -u admin:geoserver --write-out %{http_code} -XPOST -H 'Content-type: text/xml' -d "<featureType><name>$layername</name><srs>EPSG:4326</srs><nativeBoundingBox><minx>0</minx><miny>0</miny><maxx>-1</maxx><maxy>-1</maxy></nativeBoundingBox><latLonBoundingBox><minx>-1</minx><miny>-1</miny><maxx>0</maxx><maxy>0</maxy></latLonBoundingBox></featureType>" http://$localip/geoserver/rest/workspaces/opencop/datastores/opencop/featuretypes`
if [ "$response" = "201" ]; then
    echo "Success."
else
    echo "Failed. $response"
    exit 1
fi
done


echo "$p OpenAM install complete. Have a nice day."
