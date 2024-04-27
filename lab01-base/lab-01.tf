terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.39"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"

  default_tags {
    tags = {
      Stack = "IPAM Lab"
    }
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "main" {}

resource "aws_vpc_ipam" "test" {
  description = "IPAM Test"

  operating_regions {
    region_name = data.aws_region.current.name
  }

  tags = {
    Name = "IPAM Test"
  }
}

resource "aws_vpc_ipam_pool" "account" {
  description    = "IPAM Test - Account Pool"
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.test.private_default_scope_id

  tags = {
    Name = data.aws_caller_identity.main.account_id
  }
}

resource "aws_vpc_ipam_pool_cidr" "account" {
  ipam_pool_id = aws_vpc_ipam_pool.account.id
  cidr         = "10.0.0.0/16"
}

resource "aws_vpc_ipam_pool" "region" {
  description         = "IPAM Test - Region Pool - ${data.aws_region.current.name}"
  address_family      = "ipv4"
  ipam_scope_id       = aws_vpc_ipam_pool.account.ipam_scope_id
  locale              = data.aws_region.current.name
  source_ipam_pool_id = aws_vpc_ipam_pool.account.id

  tags = {
    Name = data.aws_region.current.name
  }
}

resource "aws_vpc_ipam_pool_cidr" "region" {
  ipam_pool_id   = aws_vpc_ipam_pool.region.id
  netmask_length = 20
}

resource "aws_vpc" "vpc" {
  ipv4_ipam_pool_id   = aws_vpc_ipam_pool.region.id
  ipv4_netmask_length = 24
  depends_on          = [aws_vpc_ipam_pool_cidr.region]

  tags = { Name = data.aws_region.current.name }
}

