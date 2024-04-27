provider "aws" {
  region = "ap-southeast-2"
  default_tags {
    tags = { Stack = "IPAM Lab" }
  }
}

locals {
  account_id_1 = "111111111111"
  account_id_2 = "222222222222"
}

provider "aws" {
  region = "ap-southeast-2"
  alias  = "spoke01"

  assume_role {
    role_arn = "arn:aws:iam::${local.account_id_1}:role/SharedServices-AdministratorAccess"
  }

  default_tags {
    tags = { Stack = "IPAM Lab" }
  }
}

provider "aws" {
  region = "ap-southeast-2"
  alias  = "spoke02"

  assume_role {
    role_arn = "arn:aws:iam::${local.account_id_2}:role/SharedServices-AdministratorAccess"
  }

  default_tags {
    tags = { Stack = "IPAM Lab" }
  }
}

provider "aws" {
  region = "us-west-2"
  alias  = "spoke03"

  assume_role {
    role_arn = "arn:aws:iam::${local.account_id_1}:role/SharedServices-AdministratorAccess"
  }

  default_tags {
    tags = { Stack = "IPAM Lab" }
  }
}
