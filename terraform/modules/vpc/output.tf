#used if sg module
output "vpc_id" {
  description = "value for vpc id used in other module"
  value = aws_vpc.main_network.id
}
output "vpc_cidr"{
   description = "value for vpc CICD used in other module"
   value = aws_vpc.main_network.cidr_block
}

#used in alb module
output "pub_subnet_id" {
  description = "value for pub subnet used in other module"
  value = aws_subnet.public_subnet.*.id
}

output "pri_subnet_id" {
  description = "value for pri subnet used in other module"
  value = aws_subnet.private_subnet.*.id
}