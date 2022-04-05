locals {
  nonprod_domain = "vulnerability-reporting.nonprod-service.security.gov.uk"
  nonprod_tags = {
    "Service" : "GCCC - VRS - DNS",
    "Reference" : "https://github.com/co-cddo/gccc-vrs-iac",
    "Environment" : "nonprod"
  }
}

resource "aws_route53_zone" "vrs-np-sec-gov-uk" {
  name = local.nonprod_domain

  tags = merge(
    { "Name" : local.nonprod_domain },
    local.nonprod_tags
  )
}

data "aws_cloudfront_distribution" "nonprod-cdn" {
  id = "ETHO2U176O6VX"
}

resource "aws_route53_record" "a" {
  zone_id = aws_route53_zone.vrs-np-sec-gov-uk.zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = data.aws_cloudfront_distribution.nonprod-cdn.domain_name
    zone_id                = data.aws_cloudfront_distribution.nonprod-cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "aaaa" {
  zone_id = aws_route53_zone.vrs-np-sec-gov-uk.zone_id
  name    = ""
  type    = "AAAA"

  alias {
    name                   = data.aws_cloudfront_distribution.nonprod-cdn.domain_name
    zone_id                = data.aws_cloudfront_distribution.nonprod-cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www-a" {
  zone_id = aws_route53_zone.vrs-np-sec-gov-uk.zone_id
  name    = "www"
  type    = "A"

  alias {
    name                   = data.aws_cloudfront_distribution.nonprod-cdn.domain_name
    zone_id                = data.aws_cloudfront_distribution.nonprod-cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www-aaaa" {
  zone_id = aws_route53_zone.vrs-np-sec-gov-uk.zone_id
  name    = "www"
  type    = "AAAA"

  alias {
    name                   = data.aws_cloudfront_distribution.nonprod-cdn.domain_name
    zone_id                = data.aws_cloudfront_distribution.nonprod-cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "np-google-console" {
  zone_id = aws_route53_zone.vrs-np-sec-gov-uk.zone_id
  name    = "."
  type    = "TXT"
  records = ["google-site-verification=ZA1BGfGTtQQELKFbcQH85K28Iea-kOF1x0X1O9MZULw"]
}

module "vrs-np-aws-r53-parked-domain" {
  source            = "github.com/co-cddo/aws-route53-parked-govuk-domain//terraform?ref=829478ba8ed41863d7e5f526475de3e09171da4d"
  zone_id           = aws_route53_zone.vrs-np-sec-gov-uk.zone_id
  depends_on        = [aws_route53_zone.vrs-np-sec-gov-uk]
  email_records     = true  # default
  webserver_records = false # default
}
