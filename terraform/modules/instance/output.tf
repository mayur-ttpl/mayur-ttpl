output "ec2_details" {
  value = aws_instance.ec2
}
output "eip" {
  value = aws_eip.pub_ip_fixed[0].public_ip
}