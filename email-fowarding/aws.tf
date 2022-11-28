provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      "Service" : "vulnerability-reporting.service.security.gov.uk",
      "Reference" : "https://github.com/co-cddo/gccc-vrs-iac",
      "Environment" : terraform.workspace
    }
  }
}

terraform {
  backend "s3" {
    bucket = "gccc-vrs-tfstate"
    key    = "gccc-vrs-email-fowarding.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-1"
  alias  = "eu_west_1"

  default_tags {
    tags = {
      "Service" : "vulnerability-reporting.service.security.gov.uk",
      "Reference" : "https://github.com/co-cddo/gccc-vrs-iac",
      "Environment" : terraform.workspace
    }
  }
}
