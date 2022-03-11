provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      "Service" : "GCCC - VRS - CDN",
      "Reference" : "https://github.com/co-cddo/gccc-vrs-iac",
      "Environment" : terraform.workspace
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"

  default_tags {
    tags = {
      "Service" : "GCCC - VRS - CDN",
      "Reference" : "https://github.com/co-cddo/gccc-vrs-iac",
      "Environment" : terraform.workspace
    }
  }
}

terraform {
  backend "s3" {
    bucket = "gccc-vrs-tfstate"
    key    = "gccc-vrs-cdn.tfstate"
    region = "eu-west-2"
  }
}
