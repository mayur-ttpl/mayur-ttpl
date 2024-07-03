#this will get all value for sg , we get specific value from root module using module name
output "sg_id" {
  value = aws_security_group.sg.id
}