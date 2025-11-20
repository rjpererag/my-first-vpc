# vpc/ec2.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../vpc"
}