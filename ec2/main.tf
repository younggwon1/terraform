locals {
  vpc_id             = data.terraform_remote_state.network.outputs.vpc_id
  public_subnet_ids  = data.terraform_remote_state.network.outputs.public_subnets_ids
  private_subnet_ids = data.terraform_remote_state.network.outputs.private_subnets_ids
  acm                = data.terraform_remote_state.acm.outputs.acm_certificate_arn
}

module "ec2_c_type_instance" {
  source              = "./modules/ec2-instance"
  vpc_id              = local.vpc_id
  instance_type       = "c5.large"
  root_volume_type    = "gp3"
  root_volume_size    = 64
  ebs_volume_type     = "gp3"
  ebs_volume_size     = 128
  ebs_iops            = 3000
  ebs_throughput      = 125
  public_subnet_ids   = local.public_subnet_ids
  private_subnet_id   = local.private_subnet_ids[0]
  team                = "Compute Team"
  name_prefix         = "c-type"
  acm_certificate_arn = local.acm
}

module "ec2_m_type_instance" {
  source              = "./modules/ec2-instance"
  vpc_id              = local.vpc_id
  instance_type       = "m5.large"
  root_volume_type    = "gp3"
  root_volume_size    = 64
  ebs_volume_type     = "gp3"
  ebs_volume_size     = 128
  ebs_iops            = 3000
  ebs_throughput      = 125
  public_subnet_ids   = local.public_subnet_ids
  private_subnet_id   = local.private_subnet_ids[1]
  team                = "Backend Team"
  name_prefix         = "m-type"
  acm_certificate_arn = local.acm
}

module "ec2_t_type_instance" {
  source              = "./modules/ec2-instance"
  vpc_id              = local.vpc_id
  instance_type       = "t3.medium"
  root_volume_type    = "gp3"
  root_volume_size    = 16
  ebs_volume_type     = "gp3"
  ebs_volume_size     = 32
  ebs_iops            = 3000
  ebs_throughput      = 125
  public_subnet_ids   = local.public_subnet_ids
  private_subnet_id   = local.private_subnet_ids[0]
  team                = "QA Team"
  name_prefix         = "t-type"
  acm_certificate_arn = local.acm
}
