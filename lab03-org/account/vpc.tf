terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.39"
    }
  }
}

variable "vpc_netmask_length" {
  type        = number
  description = "Netmask length for the default VPC"
  default     = 24
}

variable "regional_pools" {
  type = map(string)
  description = "Dict of IPAM pool IDs for each reagion"
}

variable "resource_share" {
  type = string
  description = "ARN of the Resource Share for the IPAM pool"
}

data "aws_caller_identity" "deploy" {}
data "aws_region" "deploy" {}

#resource "aws_ram_resource_share_accepter" "ipam_pool" {
#  share_arn = var.resource_share
#}

resource "aws_vpc" "vpc" {
  #  depends_on = [aws_ram_resource_share_accepter.ipam_pool]

  ipv4_ipam_pool_id = var.regional_pools[data.aws_region.deploy.name]
  ipv4_netmask_length = var.vpc_netmask_length

  tags = {
    Name = "${data.aws_caller_identity.deploy.account_id}/${data.aws_region.deploy.name}"
  }
}
