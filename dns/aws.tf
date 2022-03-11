provider "aws" {
  region = "eu-west-2"
}

terraform {
  backend "s3" {
    bucket = "gccc-vrs-tfstate"
    key    = "gccc-vrs-dns.tfstate"
    region = "eu-west-2"
  }
}
