variable "hosted_zone_name" {
  description = "Name of already created hosted zone in aws"
}
variable "domain_name" {
  description = "value for domain to add for plain A records"
  default = ""
}
variable "target_ip" {
  description = "value for target IP for plain A records"
  default = []
}
variable "domain_name2" {
  description = "value for domain to add for alias A records"
  default = ""
}
variable "alias_name" {
  description = "value for Target resource to add as alias"
  default = ""
}
variable "alias_zone_id" {
  description = "value for target resource zone add as alias"
  default = ""
}
variable "base_domain" {}