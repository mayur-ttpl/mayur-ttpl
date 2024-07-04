#to change ALLOWED_HOSTS = [] to ALLOWED_HOSTS = ['*'] in setting.py file in linux shell 
$ sed -i -e "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = ['*']/g" settings.py

#same thing using Jenkins 
$ sed -i -e "s/ALLOWED_HOSTS = \\[\\]/ALLOWED_HOSTS = ['*']/g" settings.py



####sed in yaml to append with proper indentation using target file keyword with tmp file [add space while appends]
#here "scrape_configs" is the keyword in config.yaml
$ awk '/scrape_configs/{print; system("sed -e '\''s/^/ /'\'' cn-mysql-exporter.txt"); next} 1' config.yaml > config.yaml.tmp && mv config.yaml.tmp config.yaml

####sed in yaml to append with proper indentation using target file keyword
$ awk -i inplace '/scrape_configs/{print; system("sed -e '\''s/^//'\'' '${CN_MYSQL_SCRAPE_FILE}'"); next} 1' "${CN_CONFIG_FILE}"

#to change the https://url.com with new https://new-url.com in shell of jenkins

#in jenkins 
#here api_url: "https://website.mayur.com/commodities-dashboard/api/v1" changes to api_url: "https://dev.mayur.com/commodities-dashboard/api/v1"
sed -i -e 's/api_url: "https:\\/\\/website.mayur.com\\/commodities-dashboard\\/api\\/v1"/api_url: "https:\\/\\/dev.mayur.com\\/commodities-dashboard\\/api\\/v1"/g' src/environments/environment.prod.ts


###delete using keywords 
$ sed -i.bak -e '/job_name: '\''cn-metrics-mysql-exporter'\''/,/action:/d' config.yaml

###change in place using key only 
sed -i -e "s/DB_HOST=[^ ]*/DB_HOST=127.0.0.1/g" .env





