variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "vpc-name" {
  type    = string
  default = "vpc-labs"
}

variable "vpc-cidr" {
  type    = string
  default = "10.21.0.0/16"
}

variable "availability_zone_names" {
  type    = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "public-subnets-cidr" {
  type    = list(string)
  default = ["10.21.0.0/24", "10.21.1.0/24"]
}

variable "private-subnets-cidr" {
  type    = list(string)
  default = ["10.21.32.0/24", "10.21.33.0/24"]
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Terraform = "true"
    }
  }
}
