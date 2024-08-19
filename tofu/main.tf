terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.63.0"
    }
  }
}

provider "aws" {}
