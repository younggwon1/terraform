variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public Subnet IDs"
  type        = list(string)
}

variable "private_subnet_id" {
  description = "Private Subnet ID"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for instance name"
  type        = string
}

variable "team" {
  description = "Team name tag"
  type        = string
}

variable "extra_tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

variable "acm_certificate_arn" {
  description = "The ARN of the certificate"
  type        = string
}

variable "root_volume_type" {
  description = "Volume Type for Root"
  type        = string
}

variable "root_volume_size" {
  description = "Volume Size for Root"
  type        = number
}

variable "ebs_volume_type" {
  description = "Volume Type for EBS"
  type        = string
}

variable "ebs_volume_size" {
  description = "Volume Size for EBS"
  type        = number
}

variable "ebs_iops" {
  description = "IOPS for EBS"
  type        = number

  validation {
    condition     = var.ebs_volume_type != "gp3" || (var.ebs_iops >= 3000 && var.ebs_iops <= 16000)
    error_message = "gp3 IOPS must be between 3000 and 16000."
  }
}

variable "ebs_throughput" {
  description = "Throughput for EBS (MiB/s)"
  type        = number

  validation {
    condition     = var.ebs_volume_type != "gp3" || (var.ebs_throughput >= 125 && var.ebs_throughput <= 1000)
    error_message = "gp3 throughput must be between 125 and 1000 MiB/s."
  }
}

variable "user_data" {
  description = "User data script (cloud-init format). If not provided, default nginx setup will be used."
  type        = string
  default     = ""
}

variable "user_data_base64" {
  description = "Base64 encoded user data script"
  type        = string
  default     = ""
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "health_check" {
  description = "Health check configuration for target group"
  type = object({
    path                = string
    port                = number
    protocol            = string
    healthy_threshold   = number
    unhealthy_threshold = number
    interval            = number
    timeout             = number
    matcher             = string
  })
  default = {
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    matcher             = "200-399"
  }
}

variable "cpu_credits" {
  description = "Credit option for CPU (standard, unlimited, null). If null, will be set based on instance type."
  type        = string
  default     = null

  validation {
    condition     = var.cpu_credits == null || contains(["standard", "unlimited"], var.cpu_credits)
    error_message = "cpu_credits must be 'standard', 'unlimited', or null."
  }
}

variable "ami_name_filter" {
  description = "AMI name filter pattern"
  type        = string
  default     = "al2023-ami-*-kernel-*-x86_64"
}

variable "enable_cloudwatch_agent" {
  description = "Enable CloudWatch Agent installation and configuration"
  type        = bool
  default     = true
}
