module "r53_acm_test_app" {
  source = "./modules/R53_ACM"
  base_domain = "*.mayur.com"
  hosted_zone_name = "mayur.com" #Name of already created hosted zone in aws
  #add for plain IP "A" records [for ui]
  domain_name = "www.mayur.com"
  target_ip = module.app_ec2.eip

  #added for alias "A" records
  domain_name2 = "api.mayur.com"
  alias_name = module.app_ui.cloudfront_dns
  alias_zone_id = module.app_ui.cloudfront_hosted_zone_id 
}
