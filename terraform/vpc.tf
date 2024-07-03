module "main-vpc" {
  source = "./modules/vpc"
  #passing value for module
  name_prefix = var.name_prefix
  aws_region = var.aws_region
  vpc_cidr_block = var.vpc_cidr_block
  az_count = var.az_count
  nat_count = var.nat_count
}

#we can use module as again and again multiple time
/*module "test-vpc" {
  source = "./modules/vpc"
  #passing value for module
  name_prefix = "uat"
  aws_region = var.aws_region
  vpc_cidr_block = "10.1.0.0/16"
  az_count = var.az_count
  nat_count = var.nat_count
}*/
