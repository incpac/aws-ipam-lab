output "ipam_pool_id" {
  description = "ID of the VPC IPAM pool"
  value = aws_vpc_ipam_pool.deploy.id
}
