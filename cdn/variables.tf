locals {
  acknowledgements = [
    [
      "Chris Nesbitt-Smith",
      "2026-06-01",
      "Potential Improper Authentication vulnerability in multiple GOV.UK sites"
    ], 
    [
      "exss",
      "2026-04-01",
      "A series of potential business logic vulnerabilities and exposed information across multiple GOV.UK sites"
    ], 
    [
      "Cagri Eser",
      "2025-10-13",
      "A series of potential vulnerability types across multiple GOV.UK sites"
    ],    
    [
      "Miguel Llamazares",
      "2025-06-26",
      "Potential Improper Authentication vulnerability in a GOV.UK site"
    ],
    [
      "Finley McGregor",
      "2024-10-22",
      "Potential SQL injection vulnerability in multiple GOV.UK sites"
    ]
  ]

  footerlinks = [
    [
      "Acknowledgements",
      "/acknowledgements",
      ""
    ],
    [
      "Feedback",
      "/feedback",
      ""
    ],
    [
      "security.txt",
      "/.well-known/security.txt",
      "target='_blank'"
    ],
    [
      "Organisation Configuration",
      "/config",
      ""
    ]
  ]

  origin_id      = terraform.workspace == "prod" ? "vulnerability-reporting_service_security_gov_uk" : "vulnerability-reporting_nonprod-service_security_gov_uk"
  primary_domain = terraform.workspace == "prod" ? "vulnerability-reporting.service.security.gov.uk" : "vulnerability-reporting.nonprod-service.security.gov.uk"

}

variable "basicauthstring" {
  type = string
}
