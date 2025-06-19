terraform {
  backend "s3" {
    key = "devops-unisatc-a3/terraform.tfstate"
    region = "sa-east-1"
    bucket = "joelfrancisco-terraform-state"
    use_lockfile = true
  }

  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.51.0" 
  }
}

provider "aws" {
  region = "us-east-1"
}

module "test_devops" {
  source = "./resources"
}

