# backend.tf

terraform {
  backend "s3" {
    bucket         = "terraform-datadog-poc-terraform-state"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-datadog-poc-terraform-state"
  acl    = "private"
  versioning {
    enabled    = true
    mfa_delete = false
  }
}
