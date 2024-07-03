#module for IAC 
vpc.tf for vpc module [vpc, subnet, nat]

#module for sg 
just add inggress rule with all your argument as mention in existing block

#module for ec2
- use exisitng key pair if available or create key pair manually as it is a sensitive paramter and one time activity, same key pair is used for ec2 lauch process.
- use exisitng AMI with nginx virtual host setup which send proxy pass to container port.
