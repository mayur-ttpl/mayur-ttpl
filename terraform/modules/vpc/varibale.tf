
variable "name_prefix" {
  description = "nameing prefix for resources"  
}
variable "aws_region" {
    description = "aws region"
}
variable "vpc_cidr_block" {
  type = string
  description = "CIDR rage for VPC"
}
variable "az_count" {
    description = "count used while subnet creation"
}
variable "nat_count" {
  description = "value for number of eip for nat gateway"
}