module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.1"

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

  create_igw = true

  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${var.vpc_name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${var.vpc_name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${var.vpc_name}-default" }

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_flow_log                      = var.enable_flow_log
  create_flow_log_cloudwatch_log_group = var.enable_flow_log ? var.create_flow_log_cloudwatch_log_group : false
  create_flow_log_cloudwatch_iam_role  = var.enable_flow_log ? var.create_flow_log_cloudwatch_iam_role : false
  flow_log_max_aggregation_interval    = var.enable_flow_log ? var.flow_log_max_aggregation_interval : null
  flow_log_traffic_type                = var.enable_flow_log ? var.flow_log_traffic_type : null

  tags = {
    Resource = "Network"
  }
}
