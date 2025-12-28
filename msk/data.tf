data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "tf-remote-state"
    key    = "ap-northeast-2.network.tfstate"
    region = "ap-northeast-2"
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
