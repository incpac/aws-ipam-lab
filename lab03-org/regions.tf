data "aws_region" "main" {}
data "aws_region" "spoke01" { provider = aws.spoke01 }
data "aws_region" "spoke02" { provider = aws.spoke02 }
data "aws_region" "spoke03" { provider = aws.spoke03 }
data "aws_caller_identity" "main" {}

locals {
  operating_regions = distinct([
    data.aws_region.main.name,
    data.aws_region.spoke01.name,
    data.aws_region.spoke02.name,
    data.aws_region.spoke03.name,
  ])
}

module "regions" {
  for_each = toset(local.operating_regions)

  source = "./region"

  parent_pool_id = aws_vpc_ipam_pool.shared.id
  region         = each.value
  netmask_length = 13
}

locals {
  regional_pools = {
    for k, v in module.regions : k => v.ipam_pool_id
  }
}
