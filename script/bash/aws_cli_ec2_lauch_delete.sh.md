#!/bin/bash
APPPORTNUMBER=$1
APPNAME=$2

#Declaring Variables
vpc_id=vpc-e332298b
subnet_id=subnet-d85f5fb0
ami_id=ami-07ffb2f4d65357b42
instancename=$APPNAME
sgname=$APPNAME

#creating SG
#echo "creating security group $sgname"
aws ec2 create-security-group --group-name $sgname --description "created for alchemy-poc"  --vpc-id "$vpc_id"  --output text >  /dev/null 2>&1
#retrieving the group-id of the security group created
sgid=`aws ec2 describe-security-groups  --query "SecurityGroups[].GroupId" --filters "Name=group-name,Values=$sgname" | sed -n 2p | tr -d \"`
#Adding the inbound rules to the security group created
aws ec2 authorize-security-group-ingress --group-id $sgid --protocol tcp --port 22 --cidr 0.0.0.0/0  >  /dev/null 2>&1
aws ec2 authorize-security-group-ingress --group-id $sgid --protocol tcp --port $APPPORTNUMBER --cidr 0.0.0.0/0  >  /dev/null 2>&1
echo "security group created $sgid"

#Launching the instance with same key as used while launching jenkins server, copy this key in /var/lib/jenkins/.ssh/alcemy_tech.pem"
aws ec2 run-instances --image-id $ami_id --count 1 --instance-type t3.small --key-name alcemy_tech  --security-group-ids $sgid --subnet-id $subnet_id  --block-device-mappings "[{\"DeviceName\":\"/dev/sdf\",\"Ebs\":{\"VolumeSize\":10,\"DeleteOnTermination\":true}}]"  --tag-specification "ResourceType=instance,Tags=[{Key=Name,Value=$instancename}]" --output text  >  /dev/null 2>&1
sleep 1m  

#retrieving the id and public ip of the newly created ec2
INSTANCEID=`aws ec2 describe-instances  --filters "Name=tag:Name,Values=$APPNAME" --query 'Reservations[].Instances[].[InstanceId]' --output text`
INSTANCEIP=`aws ec2 describe-instances --instance-ids $INSTANCEID --query 'Reservations[*].Instances[*].PublicIpAddress' --output text`

#add entry to config file 
sed -i -e "/$APPNAME/,+4d" ~/.ssh/config
echo "
Host $APPNAME
  HostName $INSTANCEIP
  User ubuntu
  IdentityFile ~/.ssh/alchemy_tech.pem
" >> ~/.ssh/config

echo "APPLICATION URL: $INSTANCEIP:$APPPORTNUMBER" 

#setting up termination
crontab -l | { cat; echo "*/10 * * * * aws ec2 terminate-instances --instance-ids $INSTANCEID"; } | crontab -
crontab -l | { cat; echo "*/12 * * * * root aws ec2 delete-security-group --group-id sg-903004f8 $sgid"; } | crontab -
