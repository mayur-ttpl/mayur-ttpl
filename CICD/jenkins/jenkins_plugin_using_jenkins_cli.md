######install plugin using cli ########
git-parameter
saferestart

#install jenkins-cli.jar
wget http://localhost:8080/jnlpJars/jenkins-cli.jar

#plusgin names list and url if required
https://updates.jenkins-ci.org/download/plugins/

#install plusgin using name 
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth mayur:mayur install-plugin saferestart
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth mayur:mayur install-plugin git-parameter

#from other user using cli and cred
sudo java -jar /root/jenkins-cli.jar -s http://localhost:8080/ -auth mayur:mayur install-plugin thinBackup

#restart 
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth mayur:mayur safe-restart


###list plugin
$ java -jar jenkins-cli.jar -s http://localhost:8080/ -auth mayur:mayur list-plugins > plugin-list.txt
#get list in proper format
$ awk '{print $1}' plugin-list.txt

