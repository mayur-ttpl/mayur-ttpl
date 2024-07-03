terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "> 5.0" #version more than 5
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  #profile = "mayur-root"
}