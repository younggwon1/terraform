variable "domain_name" {
  description = "Domain Name"
  type        = string
  default     = "test.com"
}

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.23.0"
    }
  }

  backend "s3" {
    bucket       = "tf-remote-state"
    key          = "ap-northeast-2.acm.tfstate"
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
