#craete EIP 
resource "aws_eip" "pub_ip_fixed" {
  count = var.required_public_eip ? var.instance_count : 0
  domain = "vpc"
  tags = {name = "${var.name}-eip"}
}

resource "aws_instance" "ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  count = var.instance_count
  key_name = var.key_name
  user_data = data.template_cloudinit_config.config.rendered
  subnet_id = element(var.subnet_id,count.index)
  iam_instance_profile   = var.iam_instance_profile
  vpc_security_group_ids = [var.sg_id]
  associate_public_ip_address = var.associate_public_ip_address

  root_block_device {
  volume_type = "gp3"
  volume_size = var.root_volume_size
  encrypted = true
    }
  tags = {
    Name = "${var.name_prefix}-${var.name}"
  }
  volume_tags = {
    Name = "${var.name_prefix}-${var.ebs_name}"
  }
  lifecycle {
    ignore_changes = [
      vpc_security_group_ids
    ]
  }
}

resource "aws_eip_association" "eip_assoc" {
  count = var.required_public_eip ? var.instance_count : 0
  instance_id   = element(aws_instance.ec2[*].id, count.index)
  allocation_id = element(aws_eip.pub_ip_fixed[*].id, count.index)
}