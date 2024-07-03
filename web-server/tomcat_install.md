https://vegastack.com/tutorials/how-to-install-tomcat-9-on-ubuntu-22-04/
https://www.digitalocean.com/community/tutorials/how-to-install-apache-tomcat-10-on-ubuntu-20-04

$ sudo apt update
$ sudo apt install openjdk-11-jdk
$ sudo useradd -m -d /opt/tomcat -U -s /bin/false tomcat
$ cd /tmp
https://tomcat.apache.org/download-10.cgi
#https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.13/bin/apache-tomcat-10.1.13.tar.gz

$ wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.13/bin/apache-tomcat-10.1.13.tar.gz
$ tar -xzvf apache-tomcat-10.1.13.tar.gz -C /opt/
$ mv /opt/apache-tomcat-10.1.13 /opt/tomcat
$ sudo chown -R tomcat:tomcat /opt/tomcat/
$ sudo chmod -R 711 /opt/tomcat/bin
$ sudo chmod -R 777 /opt/tomcat/logs
 #then test service running using bash
 
 #set this as a daemon process using below steps
 #check java location used for tomcat.service file  
$ sudo update-java-alternatives -l
$ vi /etc/systemd/system/tomcat.service
	[Unit]
	Description=Tomcat servlet container
	After=network.target

	[Service]
	Type=forking
	User=tomcat
	Group=tomcat
	Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
	Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom -Djava.awt.headless=true"
	Environment="CATALINA_BASE=/opt/tomcat"
	Environment="CATALINA_HOME=/opt/tomcat"
	Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
	Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
	ExecStart=/opt/tomcat/bin/startup.sh
	ExecStop=/opt/tomcat/bin/shutdown.sh

	[Install]
	WantedBy=multi-user.target 

$ sudo systemctl daemon-reload
$ sudo systemctl start tomcat
$ sudo systemctl status tomcat
$ sudo systemctl enable tomcat
