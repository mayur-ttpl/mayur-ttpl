1. jenkins install and nginx on bastion host
2. setup jenkins with git and maven.
3. run project to create .jar locally. 
4. execute .jar locally and access it.
5. create another server with java install & allow traffic from jenkins server(this is a production server)
6. setup ssh keys and config file to access production server. 
7. deploy .jar file to production server on tergat location and excute it using pipeline and normal joobs on diff port. 
8. setup nginx reverse proxy with ssl/tls certificate to access production`s server application (.jar) throgh bastion host by end user.
Jenkins installation 
Install java 
java -version
sudo apt install default-jdk
Install Jenkins 
sudo mkdir -p /usr/share/keyrings
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \                     https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins
sudo systemctl status Jenkins
sudo systemctl enable Jenkins 
#also setup some of swap memory for Jenkins server to avoid storage issue. (here I setup current ram*2=2gb)

<serverip>:8080
#Install suggested plugin 

 GitHub integration with Jenkins
Install Git plugin
       Navigate to Manage Jenkins -> Manage Plugins -> Available -> search and download 'Github                                          plugin’ & ‘github API plugin’ -> install    
Crete and add Github API to Jenkins
     Create personal access token in Github.
Navigate to Manage Jenkins -> manage credentials -> stored scope to jenkins -> global                        -> Add credentials
 Kind –secret text
Scope- global
Secret- <paste token here> 
ID - Github_API_token
Description - Github_API_token
Add Github account credentials to Jenkins
    Navigate to Manage Jenkins -> manage credentials -> stored scope to jenkins -> global                        -> Add credentials
               Scope- global
Username - <github username>
Password - <github_password>
ID - github_credentials

Description - github_credentials 
#test connection by adding github api to ‘manage Jenkins->configure system->github server’  . 
Maven integration with Jenkins
          Dashboard -> Manage Jenkins-> Global Tool Configuration->maven->add maven->name->’maven’
->’install automatically required version’.
Create a <.jar> file and test it locally
New item-><job name>->freestyle project
          General
Description -test on local
github project -<paste the github repo link>
                        Source Code Management
<paste the github repo link and select credentials>
                        Build Steps
Maven version - <select maven version which we configure before>
Goals –package <we can create step by step job also like validate, compile, test etc>
Save and apply 
Build now – it will create a .jar file inside jenkins home directory              (/var/lib/Jenkins/workspace/<job name>/target)
Now run the jar file using 
Java -jar demo-0.0.1-SNAPSHOT.jar --server.port=<port number on which want to run>	
   #by default it will run on port 8080 but here 8080 is already in use by Jenkins.


Create a production server for deployment 
create server with allow traffic from Jenkins server only with java install on it. 
Configure production server to send artifact 
on Jenkins server create key pair 
su Jenkins
ssh-keygen -t rsa -m PEM  -> rsa key generated 
cd /var/lib/Jenkins/.ssh/cat id_rsa
#copy the public key 
On production server
vi .ssh/authorized_keys
#paste the key here 

Chmod 0400 .ssh/authorized_keys
Chmod 0700 .ssh 
#from Jenkins server ssh Ubuntu@<private ip of production server> 

#also configure ssh config file for easy access of production server without mentioning ip and username 
Create config file on Jenkins server at .ssh locations
su Jenkins
vi /var/lib/Jenkins/.ssh/config
HOST production 
IdentityFile ~/.ssh/id_rsa --> private ip path which we created for production server`s  access	 
user Ubuntu --> username 
Hostname 172.31.33.254 -->ip od production server
#test the connection using --> ssh production -->we are on production server

Create a job to deploy to production 
             Or 
Create  Pipeline script
pipeline {
    agent any

    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "M3"
    }

    stages {
        stage('SCM') {
            steps {
                // Get some code from a GitHub repository
                git branch: 'main', credentialsId: 'github_credentials', url: 'https://github.com/madanmayur/java-web-app.git'
            }
        }
        stage('Validate') {
            steps {
                // validate the code
               sh 'mvn validate'
            }
        }
        stage('package') {
            steps {
                // package into .jar
               sh 'mvn package'
            }
        }
        stage('deploy') {
            steps {
                // send artifact to production
               sh 'scp **/*.jar production:/home/ubuntu' --> here production is host on which we want to send artifact  
               sh 'ssh production java -jar /home/ubuntu/*.jar –server.port=8181'   #app run on port 8181             
               
            }
        }    
    }
}


Setup nginx reverse proxy 

Map the domain name (taskone.mayur.cf) with ip address of bastion/Jenkins server

sudo apt-get install certbot python3-certbot-nginx –y
sudo certbot certonly --agree-tos --email mayurmadan@gmail.com -d taskone.mayur.cf 
ls /etc/letsencrypt/live/*mayur.cf/
vi /etc/nginx/sites-available/taskone.conf
  server {
             # Binds the TCP port 80.
       listen 80;
             # Defines the domain or subdomain name.
       
       server_name taskone.mayur.cf;
             # Redirect the traffic to the corresponding
             # HTTPS server block with status code 301
       return 301 https://$host$request_uri;
       }

server {
        # Binds the TCP port 443 and enable SSL.
        listen 443 ssl;
              # Defines the domain or subdomain name.
        server_name taskone.mayur.cf;

              # Path of the SSL certificate
        ssl_certificate /etc/letsencrypt/live/taskone.mayur.cf/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/taskone.mayur.cf/privkey.pem;
              # Use the file generated by certbot command.
        include /etc/letsencrypt/options-ssl-nginx.conf;
              # Define the path of the dhparam.pem file.
        ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

         location / {
                proxy_pass http:// 172.31.33.254:8181;
     }
}

sudo systemctl reload nginx
sudo nginx -t

