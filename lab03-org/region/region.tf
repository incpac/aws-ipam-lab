data "aws_vpc_ipam_pool" "parent" {
  ipam_pool_id = var.parent_pool_id
}

resource "aws_vpc_ipam_pool" "deploy" {
  description         = "Region Pool - ${var.region}"
  address_family      = "ipv4"
  ipam_scope_id       = data.aws_vpc_ipam_pool.parent.ipam_scope_id
  locale              = var.region
  source_ipam_pool_id = data.aws_vpc_ipam_pool.parent.ipam_pool_id
}

resource "aws_vpc_ipam_pool_cidr" "deploy" {
  ipam_pool_id   = aws_vpc_ipam_pool.deploy.id
  netmask_length = var.netmask_length
}
