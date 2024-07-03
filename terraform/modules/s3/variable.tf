variable "aws_region" {
  type        = string
  description = "AWS Region"
}
variable "name_prefix" {
  type        = string
  description = "The prefix to be added to resource names"
}
/*variable "ui_domain_name" {
  type        = string
  description = "The domain name for the website."
}*/
variable "bucket_name" {
  type        = string
  description = "The name of the bucket without the www. prefix. Normally domain_name."
}
variable "version_enabled" {
  description = "A boolean flag to enable or disable S3 bucket versioning"
}

variable "user_landing_page" {
  description = "sepcify the default root object for cloudfront"
}
variable "Managed-CachingOptimized-policy" {
  description = "ID for aws managed policy ID of cache"
}

variable "acm_arn" {
  description = "Value to pass for acm certifcate"  
}