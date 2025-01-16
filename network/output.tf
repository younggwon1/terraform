## VPC
output "vpc-id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

## Public Subnet
output "public-subnets-ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets.IDs
}
