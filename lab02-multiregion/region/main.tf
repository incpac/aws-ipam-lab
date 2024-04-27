terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.39"

      configuration_aliases = [aws.primary, aws.region]
    }
  }
}

variable "parent_pool_id" {
  type        = string
  description = "ID of the parent IPAM Pool"
}

variable "vpc_cidr_size" {
  type        = number
  description = "Size of the VPC CIDR block"
}

data "aws_region" "region" { provider = aws.region }

data "aws_vpc_ipam_pool" "parent" {
  provider = aws.primary
  ipam_pool_id = var.parent_pool_id
}

resource "aws_vpc_ipam_pool" "region" {
  provider = aws.primary

  description         = "Region Pool - ${data.aws_region.region.name}"
  address_family      = "ipv4"
  ipam_scope_id       = data.aws_vpc_ipam_pool.parent.ipam_scope_id
  locale              = data.aws_region.region.name
  source_ipam_pool_id = data.aws_vpc_ipam_pool.parent.ipam_pool_id

  tags = { Name = data.aws_region.region.name }
}

resource "aws_vpc_ipam_pool_cidr" "region" {
  provider = aws.primary

  ipam_pool_id   = aws_vpc_ipam_pool.region.id
  netmask_length = var.vpc_cidr_size
}

resource "aws_vpc" "vpc" {
  provider = aws.region
  ipv4_ipam_pool_id   = aws_vpc_ipam_pool.region.id
  ipv4_netmask_length = var.vpc_cidr_size
  depends_on          = [aws_vpc_ipam_pool_cidr.region]

  tags = { Name = data.aws_region.region.name }
}
