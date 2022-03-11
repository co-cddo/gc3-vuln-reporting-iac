locals {
  origin_id      = "${terraform.workspace == "prod" ? "vulnerability-reporting_service_security_gov_uk" : "vulnerability-reporting_nonprod-service_security_gov_uk"}"
  primary_domain = "${terraform.workspace == "prod" ? "vulnerability-reporting.service.security.gov.uk" : "vulnerability-reporting.nonprod-service.security.gov.uk"}"
}
