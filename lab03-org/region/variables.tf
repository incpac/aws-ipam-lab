variable "parent_pool_id" {
  description = "ID of the parent address pool"
  type        = string
}

variable "netmask_length" {
  description = "Length of the Netmask to allocate to this region"
  type        = number
}

variable "region" {
  description = "Region to create the address pool for"
  type        = string
}
