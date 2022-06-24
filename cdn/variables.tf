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
    ],
    [
      "Ayush Juneja",
      "2022-05-27",
      "Potential vulnerability with GOV.UK contact forms"
    ],
    [
      "Michael Minchinton",
      "2022-06-06",
      "Cached URLs linking to sensitive files on a GOV.UK service"
    ],
    [
      "Tom Samson",
      "2022-06-06",
      "Potential vulnerability to Log4j exploit in GOV.UK hosted application"
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

variable "basicauthstring" {
  type = string
}
