#!/bin/bash
set -x

##docker install on ubuntu
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

#install docker latest version
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo systemctl enable docker
echo "docker installation completed"
sudo docker run -d -p 81:80  --name=test-nginx nginx:alpine

##install nginx and configure nginx 
sudo apt install nginx -y
#configure nginx virtual host
sudo touch /etc/nginx/sites-available/mywebiste.mayur.com.conf
NGINX_VIRTUAL_HOST="/etc/nginx/sites-available/mywebiste.mayur.com.conf"
echo "nginx virtual host file is $NGINX_VIRTUAL_HOST"

echo "updating the virtual host"
cat <<EOL > $NGINX_VIRTUAL_HOST
server {
listen 80;
server_name mywebiste.mayur.com mayur.com; # Edit this to your domain name
return 302 https://$host$request_uri;
client_max_body_size 100M;
}

server {
listen 443 ssl http2;
server_name mywebiste.mayur.com mayur.com; # Edit this to your domain name
client_max_body_size 100M;

ssl_session_cache builtin:1000 shared:SSL:200m;
ssl_buffer_size 1400;
ssl_certificate /etc/nginx/ssl/mayur.com/mayur_com_crt.pem;
ssl_certificate_key /etc/nginx/ssl/mayur.com/mayur_com_key.pem;
access_log /var/log/nginx/mayur.com/ssl.access.log;
error_log /var/log/nginx/mayur.com/ssl.error.log;
ssl_protocols TLSv1.2;
proxy_ssl_ciphers HIGH:!aNULL:!MD5;
ssl_ciphers "EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH+aRSA+RC4 EECDH EDH+aRSA HIGH !RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS";
ssl_prefer_server_ciphers on;

location / {
        proxy_pass http://<your target>/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header Connection "Keep-Alive";
        proxy_set_header Proxy-Connection "Keep-Alive";
        proxy_set_header    X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_read_timeout 14400;
        proxy_connect_timeout 14400;
        proxy_send_timeout 14400;
        send_timeout 14400;
        }

/*location /login {
        proxy_pass http://<your-terget>;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header Connection "Keep-Alive";
        proxy_set_header Proxy-Connection "Keep-Alive";
        proxy_set_header    X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_read_timeout 14400;
        proxy_connect_timeout 14400;
        proxy_send_timeout 14400;
        send_timeout 14400;
        }

location /api {
        proxy_pass http://<your-terget>;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header Connection "Keep-Alive";
        proxy_set_header Proxy-Connection "Keep-Alive";
        proxy_set_header    X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_read_timeout 14400;
        proxy_connect_timeout 14400;
        proxy_send_timeout 14400;
        send_timeout 14400;
        }

location /phpmyadmin {
        proxy_pass http://<your-terget>;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header Connection "Keep-Alive";
        proxy_set_header Proxy-Connection "Keep-Alive";
        proxy_set_header    X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_read_timeout 14400;
        proxy_connect_timeout 14400;
        proxy_send_timeout 14400;
        send_timeout 14400;
        }
}
EOL
sudo mkdir -p /var/log/nginx/mayur.com/
sudo mkdir -p /etc/nginx/ssl/mayur.com/