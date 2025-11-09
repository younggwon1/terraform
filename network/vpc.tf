module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs                  = var.azs
  public_subnet_names  = var.public_subnets_names
  private_subnet_names = var.private_subnets_names
  public_subnets       = var.public_subnets_cidr
  private_subnets      = var.private_subnets_cidr

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  create_igw             = true

  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${var.vpc_name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${var.vpc_name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${var.vpc_name}-default" }

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Resource = "Network"
  }
}
