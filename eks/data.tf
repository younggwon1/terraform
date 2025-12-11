data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "tf-remote-state"
    key    = "ap-northeast-2.network.tfstate"
    region = "ap-northeast-2"
  }
}

data "aws_ami" "eks_optimized" {
  count       = var.node_ami_id == null ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-eks-${replace(var.cluster_version, ".", "-")}-x86_64-standard-*"]
  }
}
