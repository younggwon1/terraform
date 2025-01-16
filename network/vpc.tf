module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"

  name = var.vpc-name
  cidr = var.vpc-cidr

  azs             = var.availability-zone-names
  public_subnet_names =  var.public-subnets-names
  private_subnet_names = var.private-subnets-names
  public_subnets  = var.private-subnets-cidr
  private_subnets = var.public-subnets-cidr

  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = true
  
  create_igw = true

  enable_dns_hostnames = "true"
  enable_dns_support    = "true"

  tags = {
    Resource = "Network"
  }
}
