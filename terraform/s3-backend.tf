provider "aws" {
  region = "eu-central-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-datadog-poc-terraform_state"
  acl    = "private"
}
