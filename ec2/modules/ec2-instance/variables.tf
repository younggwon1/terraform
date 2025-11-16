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
}

variable "ebs_throughput" {
  description = "Throughput for EBS"
  type        = number
}
