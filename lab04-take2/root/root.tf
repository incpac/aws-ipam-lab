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
    tags = { Stack = "IPAM Lab" }
  }
}

variable "total_pool_cidr" {
  type        = string
  description = "CIDR range for the entire pool"
  default     = "10.0.0.0/8"
}

variable "operating_regions" {
  description = "List of regions to create the Pool for"
  type        = list(string)
  default     = ["ap-southeast-2", "us-west-2"]
}

data "aws_region" "current" {}

locals {
  operating_regions = distinct(concat([data.aws_region.current.name], var.operating_regions))
}

resource "aws_vpc_ipam" "main" {
  description = "IPAM Lab"

  dynamic "operating_regions" {
    for_each = local.operating_regions
    content { region_name = operating_regions.value }
  }

  tags = { Name = "IPAM Lab" }
}

resource "aws_vpc_ipam_pool" "org" {
  description = "Org Pool"

  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.main.private_default_scope_id
}

resource "aws_vpc_ipam_pool" "shared" {
  for_each = toset(local.operating_regions)

  description = "Shared Pool - ${each.value}"

  address_family      = "ipv4"
  ipam_scope_id       = aws_vpc_ipam_pool.org.ipam_scope_id
  source_ipam_pool_id = aws_vpc_ipam_pool.org.id
  locale              = each.value
}


resource "aws_ram_resource_share" "ipam_pool" {
  name                      = "IPAM Lab"
  allow_external_principals = false
  permission_arns = [
    "arn:aws:ram::aws:permission/AWSRAMDefaultPermissionsIpamPool"
  ]
}

resource "aws_ram_resource_association" "ipam_pool" {
  for_each = aws_vpc_ipam_pool.shared

  resource_arn       = each.value.arn
  resource_share_arn = aws_ram_resource_share.ipam_pool.arn
}

data "aws_organizations_organization" "org" {}

resource "aws_ram_principal_association" "org" {
  principal          = data.aws_organizations_organization.org.arn
  resource_share_arn = aws_ram_resource_share.ipam_pool.arn
}

resource "aws_vpc_ipam_pool_cidr" "org" {
  ipam_pool_id = aws_vpc_ipam_pool.org.id
  cidr         = var.total_pool_cidr
}

resource "aws_vpc_ipam_pool_cidr" "shared" {
  for_each = toset(local.operating_regions)

  ipam_pool_id = aws_vpc_ipam_pool.shared[each.value].id
  cidr         = cidrsubnet(aws_vpc_ipam_pool_cidr.org.cidr, 4, index(local.operating_regions, each.value))
}
