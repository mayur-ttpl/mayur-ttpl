#used in route 53 for alias record mapping
output "cloudfront_dns" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}
output "cloudfront_hosted_zone_id" {
  value = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
}