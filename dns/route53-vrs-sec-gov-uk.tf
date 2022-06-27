locals {
  domain = "vulnerability-reporting.service.security.gov.uk"
  prod_tags = {
    "Service" : "GCCC - VRS - DNS",
    "Reference" : "https://github.com/co-cddo/gccc-vrs-iac",
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
    "security_contact=mailto:vulnerability-reporting@cabinetoffice.gov.uk"
  ]
}

module "vrs-aws-r53-parked-domain" {
  source                 = "github.com/co-cddo/aws-route53-parked-govuk-domain//terraform?ref=5e85556ce417cd335c440fd1e7079bd331f443d5"
  zone_id                = aws_route53_zone.vrs-sec-gov-uk.zone_id
  depends_on             = [aws_route53_zone.vrs-sec-gov-uk]
  email_records          = true  # default
  webserver_records      = false # default
  additional_txt_records = [
    "google-site-verification=25QFZwLwS94r74j_X-XV8mhqL5CN-_4tHpQoDqhzJAc",
    "security_policy=https://vulnerability-reporting.service.security.gov.uk/.well-known/security.txt"
  ]
}
