terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # stable provider version
    }
  }
}

provider "aws" {
  region = "us-east-2"
}