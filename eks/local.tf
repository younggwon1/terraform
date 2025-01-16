locals {
  vpc-id = data.terraform_remote_state.network.outputs.vpc-id
  
  public-subnet-ids = [
    data.terraform_remote_state.network.outputs.public-subnets-ids,
  ]
}
