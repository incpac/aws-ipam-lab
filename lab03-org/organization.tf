resource "aws_vpc_ipam" "main" {
  description = "IPAM Lab"

  dynamic "operating_regions" {
    for_each = local.operating_regions
    content { region_name = operating_regions.value }
  }

  tags = { Name = "IPAM Lab" }
}

resource "aws_vpc_ipam_pool" "shared" {
  description = "Org Pool"

  address_family = "ipv4"
  ipam_scope_id = aws_vpc_ipam.main.private_default_scope_id
}

resource "aws_ram_resource_share" "ipam_pool" {
  name                      = "IPAM Lab"
  allow_external_principals = false
  permission_arns           = [
    "arn:aws:ram::aws:permission/AWSRAMDefaultPermissionsIpamPool"
  ]
}

resource "aws_ram_resource_association" "ipam_pool" {
  resource_arn       = aws_vpc_ipam_pool.shared.arn
  resource_share_arn = aws_ram_resource_share.ipam_pool.arn
}

data "aws_organizations_organization" "org" {}

resource "aws_ram_principal_association" "org" {
  principal          = data.aws_organizations_organization.org.arn
  resource_share_arn = aws_ram_resource_share.ipam_pool.arn
}

resource "aws_vpc_ipam_pool_cidr" "shared" {
  ipam_pool_id = aws_vpc_ipam_pool.shared.id
  cidr         = var.total_pool_cidr
}
