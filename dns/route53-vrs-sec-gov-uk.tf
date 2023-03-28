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
  ]
}

resource "aws_route53_record" "txt-prod" {
  zone_id = aws_route53_zone.vrs-sec-gov-uk.zone_id
  name    = ""
  type    = "TXT"
  ttl     = 600

  records = [
    "security_policy=https://vulnerability-reporting.service.security.gov.uk/.well-known/security.txt",
    "google-site-verification=25QFZwLwS94r74j_X-XV8mhqL5CN-_4tHpQoDqhzJAc",
    "v=spf1 mx include:mail.zendesk.com include:amazonses.com -all"
  ]
}

resource "aws_route53_record" "zendesk1-prod" {
  zone_id = aws_route53_zone.vrs-sec-gov-uk.zone_id
  name    = "zendesk1._domainkey"
  type    = "CNAME"
  ttl     = 600

  records = [
    "zendesk1._domainkey.zendesk.com",
  ]
}

resource "aws_route53_record" "zendesk2-prod" {
  zone_id = aws_route53_zone.vrs-sec-gov-uk.zone_id
  name    = "zendesk2._domainkey"
  type    = "CNAME"
  ttl     = 600

  records = [
    "zendesk2._domainkey.zendesk.com",
  ]
}

resource "aws_route53_record" "mx-records-prod" {
  zone_id = aws_route53_zone.vrs-sec-gov-uk.zone_id
  name    = "."
  type    = "MX"
  ttl     = "60"
  records = ["10 inbound-smtp.eu-west-1.amazonaws.com"]
}

resource "aws_route53_record" "dmarc-record-prod" {
  zone_id = aws_route53_zone.vrs-sec-gov-uk.zone_id
  name    = "_dmarc"
  type    = "TXT"
  ttl     = "60"
  records = [
    "v=DMARC1;p=reject;sp=reject;adkim=s;aspf=s;fo=1;rua=mailto:dmarc-rua@dmarc.service.gov.uk"
  ]
}

resource "aws_route53_record" "zendesk-record-prod" {
  zone_id = aws_route53_zone.vrs-sec-gov-uk.zone_id
  name    = "zendeskverification"
  type    = "TXT"
  ttl     = "60"
  records = [
    "5a4a93fac7830475"
  ]
}
