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

provider "aws" {
  region = "us-west-2"
  alias  = "region01"

  default_tags {
    tags = { Stack = "IPAM Lab" }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "region02"

  default_tags {
    tags = { Stack = "IPAM Lab" }
  }
}

data "aws_caller_identity" "main" {}
data "aws_region" "current" {}
data "aws_region" "region01" { provider = aws.region01 }
data "aws_region" "region02" { provider = aws.region02 }

locals {
  operating_regions = distinct([
    data.aws_region.current.name,
    data.aws_region.region01.name,
    data.aws_region.region02.name,
  ])
}

resource "aws_vpc_ipam" "test" {
  description = "IPAM Test"

  dynamic "operating_regions" {
    for_each = local.operating_regions
    content {
      region_name = operating_regions.value
    }
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

module "region01" {
  source = "./region"

  providers = {
    aws.primary = aws,
    aws.region = aws.region01,
  }

  parent_pool_id = aws_vpc_ipam_pool.account.id
  vpc_cidr_size  = 24
}

module "region02" {
  source = "./region"

  providers = {
    aws.primary = aws,
    aws.region = aws.region02,
  }

  parent_pool_id = aws_vpc_ipam_pool.account.id
  vpc_cidr_size  = 24
}
