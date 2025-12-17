locals {
  vpc_id              = data.terraform_remote_state.network.outputs.vpc_id
  vpc_cidr_block      = data.terraform_remote_state.network.outputs.vpc_cidr_block
  public_subnets_ids  = data.terraform_remote_state.network.outputs.public_subnets_ids
  private_subnets_ids = data.terraform_remote_state.network.outputs.private_subnets_ids
  nat_gateway_cidrs = [
    for nat_public_ip in data.terraform_remote_state.network.outputs.nat_public_ips :
    "${nat_public_ip}/32"
  ]
}
