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

resource "aws_route53_record" "security_txt" {
  zone_id = aws_route53_zone.vrs-np-sec-gov-uk.zone_id
  name    = "_security"
  type    = "TXT"
  ttl     = 1800

  records = [
    "security_policy=https://vulnerability-reporting.service.security.gov.uk/.well-known/security.txt",
    "security_contact=https://vulnerability-reporting.service.security.gov.uk/submit",
    "security_contact=mailto:vulnerability-reporting@cabinetoffice.gov.uk"
  ]
}

resource "aws_route53_record" "txt" {
  zone_id = aws_route53_zone.vrs-np-sec-gov-uk.zone_id
  name    = ""
  type    = "TXT"
  ttl     = 600

  records = [
    "security_policy=https://vulnerability-reporting.service.security.gov.uk/.well-known/security.txt",
    "google-site-verification=ZA1BGfGTtQQELKFbcQH85K28Iea-kOF1x0X1O9MZULw",
    "v=spf1 mx include:mail.zendesk.com include:amazonses.com -all"
  ]
}

resource "aws_route53_record" "zendesk1" {
  zone_id = aws_route53_zone.vrs-np-sec-gov-uk.zone_id
  name    = "zendesk1._domainkey"
  type    = "CNAME"
  ttl     = 600

  records = [
    "zendesk1._domainkey.zendesk.com",
  ]
}

resource "aws_route53_record" "zendesk2" {
  zone_id = aws_route53_zone.vrs-np-sec-gov-uk.zone_id
  name    = "zendesk2._domainkey"
  type    = "CNAME"
  ttl     = 600

  records = [
    "zendesk2._domainkey.zendesk.com",
  ]
}

resource "aws_route53_record" "mx-records" {
  zone_id = aws_route53_zone.vrs-np-sec-gov-uk.zone_id
  name    = "."
  type    = "MX"
  ttl     = "60"
  records = ["10 inbound-smtp.eu-west-1.amazonaws.com"]
}

resource "aws_route53_record" "dmarc-record" {
  zone_id = aws_route53_zone.vrs-np-sec-gov-uk.zone_id
  name    = "_dmarc"
  type    = "TXT"
  ttl     = "60"
  records = [
    "v=DMARC1;p=reject;sp=reject;adkim=s;aspf=s;fo=1;rua=mailto:dmarc-rua@dmarc.service.gov.uk"
  ]
}

resource "aws_route53_record" "zendesk-record" {
  zone_id = aws_route53_zone.vrs-np-sec-gov-uk.zone_id
  name    = "zendeskverification"
  type    = "TXT"
  ttl     = "60"
  records = [
    "0b1bab14858bafb5"
  ]
}

