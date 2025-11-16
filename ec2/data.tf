data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "tf-remote-state"
    key    = "ap-northeast-2.network.tfstate"
    region = "ap-northeast-2"
  }
}

data "terraform_remote_state" "acm" {
  backend = "s3"
  config = {
    bucket = "tf-remote-state"
    key    = "ap-northeast-2.acm.tfstate"
    region = "ap-northeast-2"
  }
}
