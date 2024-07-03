#data to get hosted zone id
data "aws_route53_zone" "this" {
  name         = "${var.hosted_zone_name}."
}

resource "aws_route53_record" "simple_records" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 300
  #records = ["${var.target_ip[0]}"]
   records = [var.target_ip]
}

#another domain record with alias
resource "aws_route53_record" "alias_records" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.domain_name2
  type    = "A"
  alias {
    name                   = var.alias_name
    zone_id                = var.alias_zone_id
    evaluate_target_health = false
  }
}


#wildcard ssl certificate for base domain 
resource "aws_acm_certificate" "simple_records_crt" {
  domain_name       = var.base_domain
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
} 
 # DNS records for certificate validation
resource "aws_route53_record" "simple_records_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.simple_records_crt.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.this.id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "simple_record_cert" {
  certificate_arn         = aws_acm_certificate.simple_records_crt.arn
  validation_record_fqdns = [for record in aws_route53_record.simple_records_cert_validation : record.fqdn]
  depends_on              = [aws_route53_record.simple_records_cert_validation]
}

/*

#ssl certificate for domain_name [plain records domain]
resource "aws_acm_certificate" "simple_records_crt" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
} 
 # DNS records for certificate validation
resource "aws_route53_record" "simple_records_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.simple_records_crt.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.this.id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "simple_record_cert" {
  certificate_arn         = aws_acm_certificate.simple_records_crt.arn
  validation_record_fqdns = [for record in aws_route53_record.simple_records_cert_validation : record.fqdn]
  depends_on              = [aws_route53_record.simple_records_cert_validation]
}


#ssl certificate for domain_name [alias records domain]
resource "aws_acm_certificate" "alias_records_crt" {
  domain_name       = var.domain_name2
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
} 
 # DNS records for certificate validation
resource "aws_route53_record" "alias_records_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.alias_records_crt.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.this.id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "alias_record_cert" {
  certificate_arn         = aws_acm_certificate.alias_records_crt.arn
  validation_record_fqdns = [for record in aws_route53_record.alias_records_cert_validation : record.fqdn]
  depends_on              = [aws_route53_record.alias_records_cert_validation]
}
*/