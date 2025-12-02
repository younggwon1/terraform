variable "vpc_name" {
  type        = string
  description = "The name of the VPC"
  default     = "vpc"

  validation {
    condition     = length(var.vpc_name) > 0 && length(var.vpc_name) <= 64
    error_message = "VPC name must be between 1 and 64 characters."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block of the VPC"
  default     = "10.23.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid CIDR block (e.g., 10.0.0.0/16)."
  }
}

variable "azs" {
  type        = list(string)
  description = "The availability zones of the VPC"
  default     = ["ap-northeast-2a", "ap-northeast-2c"]

  validation {
    condition     = length(var.azs) >= 2 && length(var.azs) <= 3
    error_message = "AZs must be between 2 and 3 for high availability."
  }
}

variable "public_subnets_names" {
  type        = list(string)
  description = "The names of the public subnets"
  default     = ["public-subnet-2a", "public-subnet-2c"]

  validation {
    condition     = length(var.public_subnets_names) == length(var.azs)
    error_message = "Public subnets names count must match AZs count."
  }
}

variable "private_subnets_names" {
  type        = list(string)
  description = "The names of the private subnets"
  default     = ["private-subnet-2a", "private-subnet-2c"]

  validation {
    condition     = length(var.private_subnets_names) == length(var.azs)
    error_message = "Private subnets names count must match AZs count."
  }
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "The CIDR blocks of the public subnets"
  default     = ["10.23.0.0/24", "10.23.1.0/24"]

  validation {
    condition     = length(var.public_subnets_cidr) == length(var.azs)
    error_message = "Public subnets CIDR count must match AZs count."
  }

  validation {
    condition = alltrue([
      for cidr in var.public_subnets_cidr : can(cidrhost(cidr, 0))
    ])
    error_message = "All public subnet CIDR blocks must be valid CIDR format."
  }
}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "The CIDR blocks of the private subnets"
  default     = ["10.23.32.0/24", "10.23.33.0/24"]

  validation {
    condition     = length(var.private_subnets_cidr) == length(var.azs)
    error_message = "Private subnets CIDR count must match AZs count."
  }

  validation {
    condition = alltrue([
      for cidr in var.private_subnets_cidr : can(cidrhost(cidr, 0))
    ])
    error_message = "All private subnet CIDR blocks must be valid CIDR format."
  }
}

variable "enable_flow_log" {
  type        = bool
  description = "Enable VPC Flow Logs"
  default     = false
}

variable "create_flow_log_cloudwatch_log_group" {
  type        = bool
  description = "Create CloudWatch Log Group for VPC Flow Logs"
  default     = true
}

variable "create_flow_log_cloudwatch_iam_role" {
  type        = bool
  description = "Create IAM role for VPC Flow Logs to write to CloudWatch"
  default     = true
}

variable "flow_log_max_aggregation_interval" {
  type        = number
  description = "The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record (in seconds). Valid values: 60 or 600"
  default     = 60

  validation {
    condition     = contains([60, 600], var.flow_log_max_aggregation_interval)
    error_message = "Flow log max aggregation interval must be either 60 or 600 seconds."
  }
}

variable "flow_log_traffic_type" {
  type        = string
  description = "The type of traffic to log. Valid values: ACCEPT, REJECT, or ALL"
  default     = "ALL"

  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.flow_log_traffic_type)
    error_message = "Flow log traffic type must be one of: ACCEPT, REJECT, or ALL."
  }
}
