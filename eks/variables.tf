variable "cluster-name" {
  type    = string
  default = "eks"
}

variable "cluster-version" {
  type    = string
  default = "1.31"
}

variable "cluster-addons" {
  type = map(string)
  default = {
    vpc-cni            = "v1.19.0-eksbuild.1",
    kube-proxy         = "v1.31.2-eksbuild.3",
    coredns            = "v1.11.3-eksbuild.2",
  }
}

variable "availability-zone-names" {
  type    = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

terraform {
  required_version = ">= 1.3.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.83.0"
    }
  }

  backend "s3" {
    bucket = "tf-remote-state"
    key    = "ap-northeast-2.eks.tfstate"
    region  = "ap-northeast-2"
    encrypt = true
  }
}

provider "aws" {
  region = "ap-northeast-2"

  default_tags {
    tags = {
      Terraform = "true"
    }
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "tf-remote-state"
    key    = "ap-northeast-2.network.tfstate"
    region = "ap-northeast-2"
  }
}
