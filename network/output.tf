## VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

## Public Subnet
output "public_subnets_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets.IDs
}

## Private Subnet
output "private_subnets_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets.IDs
}
