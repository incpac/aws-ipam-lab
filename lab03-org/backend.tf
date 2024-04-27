terraform {
  required_version = "~> 1.5"

  #backend "s3" {
  #  bucket = "tc-terraform-state-9112"
  #  key    = "ipam-lab3"
  #  region = "ap-southeast-2"
  #}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.39"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
