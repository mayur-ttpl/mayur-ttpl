module "alb_sg" {
  source = "./modules/sg"
  vpc_id = module.main-vpc.vpc_id
  name = "alb_sg"
  name_prefix = var.name_prefix

#specify rule here for ingress
   ingress_rules = [
    {
      #cidr_blocks = ["0.0.0.0/0"]
      cidr_blocks = [var.vpc_cidr_block]
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH connections from within vpc"
      },
      {
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow http connections from internet"      
      }
    ]
  }

#sg for ec2 
module "ec2_sg" {
  source = "./modules/sg"
  vpc_id = module.main-vpc.vpc_id
  name = "ec2_sg"
  name_prefix = var.name_prefix

#specify rule here for ingress
   ingress_rules = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      #cidr_blocks = [var.vpc_cidr_block]
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH connections from within vpc"
      },
      {
      cidr_blocks = [var.vpc_cidr_block]
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow http connections from ALB"      
      }
    ]
  }
#sg for RDS
module "rds_sg" {
  source = "./modules/sg"
  vpc_id = module.main-vpc.vpc_id
  name = "rds_sg"
  name_prefix = var.name_prefix

#specify rule here for ingress
   ingress_rules = [
      {
      cidr_blocks = [var.vpc_cidr_block]
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Allow connection to database from VPC resources"      
      }
    ]
  }

#get specific value for rds sg id,using its module name
#for id of rds_sg only
 output "rds_sg_id" {
  value = module.rds_sg.sg_id
}

#for id of ec2_sg only 
output "ec_sg_id" {
  value = module.ec2_sg.sg_id
}

#for id of alb_sg only
output "alb_sg_id" {
  value = module.alb_sg.sg_id
}