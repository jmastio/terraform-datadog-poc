# backend.tf

terraform {
  backend "s3" {
    bucket         = "terraform-datadog-poc-terraform-state"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
  }
}
