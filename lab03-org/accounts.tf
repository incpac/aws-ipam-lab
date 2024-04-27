module "spoke01" {
  depends_on = [aws_ram_principal_association.org]

  source = "./account"

  providers = {
    aws = aws.spoke01
  }

  regional_pools = local.regional_pools
  resource_share = aws_ram_resource_share.ipam_pool.arn
}

module "spoke02" {
  depends_on = [aws_ram_principal_association.org]

  source = "./account"

  providers = {
    aws = aws.spoke02
  }

  regional_pools = local.regional_pools
  resource_share = aws_ram_resource_share.ipam_pool.arn
}

module "spoke03" {
  depends_on = [aws_ram_principal_association.org]

  source = "./account"

  providers = {
    aws = aws.spoke03
  }

  regional_pools = local.regional_pools
  resource_share = aws_ram_resource_share.ipam_pool.arn
}
