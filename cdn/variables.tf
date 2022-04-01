locals {
  acknowledgements = [
    [
      "Jonathan Leitschuh",
      "2020-02-11",
      "Potential MITM using HTTP to resolve some GOV.UK Pay Maven dependencies"
    ],
    [
      "Artem Smotrakov",
      "2021-07-21",
      "Potential timing attack on GOV.UK Pay Webhook signature checks"
    ],
    [
      "Mohd.Danish Abid",
      "2022-01-17",
      "Potential directory security misconfiguration on gdscareers.gov.uk"
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

  origin_id        = "${terraform.workspace == "prod" ? "vulnerability-reporting_service_security_gov_uk" : "vulnerability-reporting_nonprod-service_security_gov_uk"}"
  primary_domain   = "${terraform.workspace == "prod" ? "vulnerability-reporting.service.security.gov.uk" : "vulnerability-reporting.nonprod-service.security.gov.uk"}"
}
