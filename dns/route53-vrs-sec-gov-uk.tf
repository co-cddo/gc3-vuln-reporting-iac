locals {
  domain = "vulnerability-reporting.service.security.gov.uk"
  prod_tags = {
    "Service" : "GC3 - VRS - DNS",
    "Reference" : "https://github.com/co-cddo/gc3-vuln-reporting-iac",
    "Environment" : "prod"
  }
}

resource "aws_route53_zone" "vrs-sec-gov-uk" {
  name = local.domain

  tags = merge(
    { "Name" : local.domain },
    local.prod_tags
  )
}

data "aws_cloudfront_distribution" "cdn-prod" {
  id = "E2RA44OZABVABR"
}

resource "aws_route53_record" "a-prod" {
  zone_id = aws_route53_zone.vrs-sec-gov-uk.zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = data.aws_cloudfront_distribution.cdn-prod.domain_name
    zone_id                = data.aws_cloudfront_distribution.cdn-prod.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "aaaa-prod" {
  zone_id = aws_route53_zone.vrs-sec-gov-uk.zone_id
  name    = ""
  type    = "AAAA"

  alias {
    name                   = data.aws_cloudfront_distribution.cdn-prod.domain_name
    zone_id                = data.aws_cloudfront_distribution.cdn-prod.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www-a-prod" {
  zone_id = aws_route53_zone.vrs-sec-gov-uk.zone_id
  name    = "www"
  type    = "A"

  alias {
    name                   = data.aws_cloudfront_distribution.cdn-prod.domain_name
    zone_id                = data.aws_cloudfront_distribution.cdn-prod.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www-aaaa-prod" {
  zone_id = aws_route53_zone.vrs-sec-gov-uk.zone_id
  name    = "www"
  type    = "AAAA"

  alias {
    name                   = data.aws_cloudfront_distribution.cdn-prod.domain_name
    zone_id                = data.aws_cloudfront_distribution.cdn-prod.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "security_txt-prod" {
  zone_id = aws_route53_zone.vrs-sec-gov-uk.zone_id
  name    = "_security"
  type    = "TXT"
  ttl     = 1800

  records = [
    "security_policy=https://vulnerability-reporting.service.security.gov.uk/.well-known/security.txt",
    "security_contact=https://vulnerability-reporting.service.security.gov.uk/submit",
  ]
}

module "co-cddo-aws-r53-parked-domain" {
  source  = "github.com/co-cddo/aws-route53-parked-govuk-domain//terraform"
  zone_id = aws_route53_zone.vrs-np-sec-gov-uk.zone_id
  additional_txt_records = [
    "security_policy=https://vulnerability-reporting.service.security.gov.uk/.well-known/security.txt",
    "google-site-verification=25QFZwLwS94r74j_X-XV8mhqL5CN-_4tHpQoDqhzJAc",
  ]
}
