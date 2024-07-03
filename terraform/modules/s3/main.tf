## S3 website bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
  tags = {
  name = "${var.name_prefix}-${var.bucket_name}"
  }
}
 #enable version for bucket
resource "aws_s3_bucket_versioning" "s3_version" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = var.version_enabled ? "Enabled" : "Disabled"
  }
}

##cloudfront
#OAC for bucket
resource "aws_cloudfront_origin_access_control" "current" {
  name                              = var.bucket_name
  description                       = "OAC authorization for S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on = [aws_s3_bucket.s3_bucket]
  #### sertup s3 as origins ###
  origin {
    domain_name              = "${var.bucket_name}.s3.${var.aws_region}.amazonaws.com"
    origin_id                = "${var.bucket_name}.s3.${var.aws_region}.amazonaws.com"
    origin_access_control_id = aws_cloudfront_origin_access_control.current.id
  }
  #price_class     = var.price_class [optional]
  enabled         = true
  is_ipv6_enabled = true
  comment         = "Distribution for ${var.bucket_name} website access with OAC"
  default_root_object = var.user_landing_page
  
  #Alternate domain names[optional]
  /*aliases = [
    var.domain_name,
    "www.${var.domain_name}"
  ]*/
   
   #### BEHAVIORS ###
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${var.bucket_name}.s3.${var.aws_region}.amazonaws.com"
    viewer_protocol_policy = "redirect-to-https"

    #CachingOptimized
    #Managed-CachingOptimized ID getting from AWS
    cache_policy_id = var.Managed-CachingOptimized-policy
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  #enable when need ssl and have valid ssl/tls ,domain etc
  viewer_certificate {
    #cloudfront_default_certificate = false
    acm_certificate_arn            = var.acm_arn
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
  tags = {
    name = "${var.name_prefix}-${var.bucket_name}-cloudfront"
  }
}

#attached policy to s3 bucket to allow access from cloudfront only.
resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.cloudfront.json
}

data "aws_iam_policy_document" "cloudfront" {
  statement {
    sid     = "AllowCloudFrontServicePrincipalReadOnly"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
        aws_s3_bucket.s3_bucket.arn,
       "${aws_s3_bucket.s3_bucket.arn}/*"
      ]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = [
        aws_cloudfront_distribution.s3_distribution.arn
      ]
    }
  }
}