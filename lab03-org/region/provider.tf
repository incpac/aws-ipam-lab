terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.39"
    }
  }
}

data "aws_region" "curent" {}
