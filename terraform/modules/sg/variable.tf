#variable "description" {}
variable "vpc_id" {}
variable "name_prefix" {}
variable "name" {}
variable "ingress_rules" {
  description = "List of ingress rules for the security group"
  type        = list(object({
    cidr_blocks = list(string)
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
  }))
}