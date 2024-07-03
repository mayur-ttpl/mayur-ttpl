module "app_ui" {
  source = "./modules/s3"
  aws_region = "us-east-1"
  name_prefix = var.name_prefix
  bucket_name = "www.mayur.com" #keep same name as route53_acm.tf module file
  #ui_domain_name = "www.mayur.com"
  version_enabled = true
  user_landing_page = "index.html"
  #acm_arn = "arn:aws:acm:us-east-1:238573859336:certificate/f112857d-996b-442c-a485-0a58cfa00db9"
   acm_arn = module.r53_acm_test_app.acm_arn
  Managed-CachingOptimized-policy = "658327ea-f89d-4fab-a63d-7e88639e58f6"
}