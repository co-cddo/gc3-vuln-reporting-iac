data "aws_caller_identity" "current" {}

locals {
  lambda_name        = "email-fowarding-${terraform.workspace}"
  iam_role           = "email-fowarding-lambda-role-${terraform.workspace}"
  iam_policy         = "email-fowarding-lambda-policy-${terraform.workspace}"

  email_domain       = "${terraform.workspace == "prod" ? "vulnerability-reporting.service.security.gov.uk" : "vulnerability-reporting.nonprod-service.security.gov.uk"}"
}

variable "mail_recipient" {
  type    = string
}
