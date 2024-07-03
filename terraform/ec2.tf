module "app_ec2" {
  source = "./modules/instance"
  instance_type = var.instance_type
  key_name  = var.key_name
  ami_id = "ami-053b0d53c279acc90"
  instance_count = var.instance_count
  name_prefix = var.name_prefix
  name = "app_ec2"
  associate_public_ip_address = "true"
  root_volume_size = "14"
  ebs_name = "app_ec2_root_volume"
  required_public_eip = true
  subnet_id = module.main-vpc.pub_subnet_id #add subnet for ec2, it is a public ec2, i.e use public subnet here.
  sg_id = module.ec2_sg.sg_id
  iam_instance_profile = aws_iam_instance_profile.EC2ECRFullAccessProfile.name #getting value from iam.tf file located in same dir.
}
output "app_ec2_eip" {
  value = module.app_ec2.eip
}
