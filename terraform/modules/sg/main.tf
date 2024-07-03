
#sg
resource "aws_security_group" "sg" {
  name        = var.name
  vpc_id = "${var.vpc_id}"
  description = "Security group for ${var.name}" 

  dynamic "ingress" {
    for_each = var.ingress_rules

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks

      description = ingress.value.description
    }
  }
    egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "${var.name_prefix}-${var.name}"
  }
}


