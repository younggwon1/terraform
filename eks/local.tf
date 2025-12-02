locals {
  vpc_id              = data.terraform_remote_state.network.outputs.vpc_id
  public_subnets_ids  = data.terraform_remote_state.network.outputs.public_subnets_ids
  private_subnets_ids = data.terraform_remote_state.network.outputs.private_subnets_ids
}
