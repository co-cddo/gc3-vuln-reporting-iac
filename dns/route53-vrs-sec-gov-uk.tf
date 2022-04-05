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

resource "aws_route53_record" "prod-google-console" {
  zone_id = aws_route53_zone.vrs-np-sec-gov-uk.zone_id
  name    = "."
  type    = "TXT"
  records = ["google-site-verification=25QFZwLwS94r74j_X-XV8mhqL5CN-_4tHpQoDqhzJAc"]
}

module "vrs-aws-r53-parked-domain" {
  source            = "github.com/co-cddo/aws-route53-parked-govuk-domain//terraform?ref=829478ba8ed41863d7e5f526475de3e09171da4d"
  zone_id           = aws_route53_zone.vrs-sec-gov-uk.zone_id
  depends_on        = [aws_route53_zone.vrs-sec-gov-uk]
  email_records     = true  # default
  webserver_records = false # default
}
