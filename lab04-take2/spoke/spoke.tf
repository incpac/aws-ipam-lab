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
  default_tags {
    tags = { Stack = "IPAM Lab" }
  }
}

variable "netmask_length" {
  description = "Length of the Netmask to allocate to this spoke"
  type        = number
}

data "aws_region" "current" {}

data "aws_vpc_ipam_pool" "pool" {
  filter {
    name   = "description"
    values = ["Shared Pool - ${data.aws_region.current.name}"]
  }
}

resource "aws_vpc" "vpc" {
  ipv4_ipam_pool_id   = data.aws_vpc_ipam_pool.pool.id
  ipv4_netmask_length = 20
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public" {
  count = length(data.aws_availability_zones.available.names)

  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, length(data.aws_availability_zones.available.names), count.index)

  tags = {
    Name = "Shared Pool - ${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_default_route_table" "table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
}
