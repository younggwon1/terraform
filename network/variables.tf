variable "vpc_name" {
  type        = string
  description = "The name of the VPC"
  default     = "vpc"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block of the VPC"
  default     = "10.23.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "The availability zones of the VPC"
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "public_subnets_names" {
  type        = list(string)
  description = "The names of the public subnets"
  default     = ["public-subnet-2a", "public-subnet-2c"]
}

variable "private_subnets_names" {
  type        = list(string)
  description = "The names of the private subnets"
  default     = ["private-subnet-2a", "private-subnet-2c"]
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "The CIDR blocks of the public subnets"
  default     = ["10.23.0.0/24", "10.23.1.0/24"]
}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "The CIDR blocks of the private subnets"
  default     = ["10.23.32.0/24", "10.23.33.0/24"]
}

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.20.0"
    }
  }

  backend "s3" {
    bucket       = "tf-remote-state"
    key          = "ap-northeast-2.network.tfstate"
    region       = "ap-northeast-2"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = "ap-northeast-2"

  default_tags {
    tags = {
      ManagedBy = "Terraform"
    }
  }
}
