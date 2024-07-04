###tunnel to DB
#should allow 22 port from your local to bastion & db port allow for db server from bastion
$ ssh -f -N -L <local-port-to-use>:<target private DB server>:<actual DB port> -o 'StrictHostKeyChecking no' -i <db-bastion-server-key.pem> <bastion-username>@<bastion pub ip>
 #example
 $ ssh -f -N -L 27000:10.100.1.212:1245 -o 'StrictHostKeyChecking no' -i <key>.pem ec2-user@54.84.0.255

$ mongosh --host <localhost> --port <local-port-to-use> -u <username>
 $ mongosh --host 127.0.0.1 --port 27000 -u caimdbadmin -p
