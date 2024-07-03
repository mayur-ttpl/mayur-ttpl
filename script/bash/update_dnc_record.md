https://dev.to/aws/amazon-route-53-how-to-automatically-update-ip-addresses-without-using-elastic-ips-h7o
https://stackoverflow.com/questions/59969304/use-one-aws-elastic-ip-for-several-instances
simple way to handle this is to add a script to each instance that runs during every boot. This script can update a DNS record to point it at the instance.
The script should go into the /var/lib/cloud/scripts/per-boot directory, which will cause Cloud-Init to automatically run the script each time the instance is started.
# Set these values based on your Route 53 Record Sets
ZONE_ID=Z3NAOAOAABC1XY
RECORD_SET=my-domain.com

# Extract information about the Instance
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id/)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone/)
MY_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4/)

# Extract Name tag associated with instance
NAME_TAG=$(aws ec2 describe-tags --region ${AZ::-1} --filters "Name=resource-id,Values=${INSTANCE_ID}" --query 'Tags[?Key==`Name`].Value' --output text)

# Update Route 53 Record Set based on the Name tag to the current Public IP address of the Instance
aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch '{"Changes":[{"Action":"UPSERT","ResourceRecordSet":{"Name":"'$NAME_TAG.$RECORD_SET'","Type":"A","TTL":300,"ResourceRecords":[{"Value":"'$MY_IP'"}]}}]}'
The script will extract the Name tag of the instance and update the corresponding Record Set in Route 53. (Feel free to change this to use a different Tag.) The instance will also require IAM permissions for ec2 describe-tags and route53 change-resource-record-sets.


