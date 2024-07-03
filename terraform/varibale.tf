
variable "name" {
  description = "Name for resources"
  default = ""
}
variable "name_prefix" {
  default = "test-app"
}
variable "aws_region" {
  default = "us-east-1"
}
variable "vpc_cidr_block" {
  type = string
  default = "172.17.0.0/16"

}
variable "az_count" {
  default = "2"
}
variable "nat_count" {
  description = "value for number of eip for nat gateway"
  default = 1
}

#ec2
variable "key_name" {
  description = "private key name for ec2 server"
  default     = "mayur-personal-aws-us-east-1"
}

variable "ami_id" {
  description = "custom ami id for ec2 server"
  default     = ""
}
variable "instance_type" {
  description = "server type for ec2"
  default = "t2.micro"
}
variable "instance_count" {
  description = "number insances to lauch"
  default = 1
}
variable "associate_public_ip_address" {
  description = "If true, the EC2 instance will have associated public IP address"
  default     = false
}
variable "root_volume_size" {
  description = "EBS backed volume size"
  default = "10"
}
variable "ebs_name" {
  description = "name for ebs volume"
  default = ""
}
variable "required_public_eip" {
  description = "EIP/Public IP required for ec2[true/false]"
  default = false
}
variable "subnet_id" {
  description = "add subnet id as per instance network requirement [pub/private]"
  default = ""
}

#s3
variable "version_enabled" {
  description = "A boolean flag to enable or disable S3 bucket versioning"
  default = false
}
