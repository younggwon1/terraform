locals {
  vpc-id = data.terraform_remote_state.network.outputs.vpc-id
  
  public-subnets-ids = [
    data.terraform_remote_state.network.outputs.public-subnets-ids,
  ]

  private-subnets-ids = [
    data.terraform_remote_state.network.outputs.private-subnets-ids,
  ]
}
