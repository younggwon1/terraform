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

variable "availability-zone-names" {
  type    = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "public-subnets-names" {
  type    = list(string)
  default = ["public-subnet-2a", "public-subnet-2c"]
}

variable "private-subnets-names" {
  type    = list(string)
  default = ["private-subnet-2a", "private-subnet-2c"]
}

variable "public-subnets-cidr" {
  type    = list(string)
  default = ["10.21.0.0/24", "10.21.1.0/24"]
}

variable "private-subnets-cidr" {
  type    = list(string)
  default = ["10.21.32.0/24", "10.21.33.0/24"]
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Terraform = "true"
    }
  }
}
