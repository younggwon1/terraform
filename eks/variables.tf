variable "cluster_name" {
  type    = string
  default = "eks"
}

variable "cluster_version" {
  type    = string
  default = "1.34"
}

variable "availability_zone_names" {
  type    = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "endpoint_public_access" {
  description = "Whether the EKS cluster endpoint is publicly accessible"
  type        = bool
  default     = false
}

variable "endpoint_private_access" {
  description = "Whether the EKS cluster endpoint is privately accessible within the VPC"
  type        = bool
  default     = true
}

variable "cluster_admin_role_arn" {
  description = "IAM Role ARN for EKS cluster admin access entry"
  type        = string
  default     = "arn:aws:iam::<account_id>:role/aws-reserved/sso.amazonaws.com/ap-northeast-2/AWSReservedSSO_<role_name>_<role_id>"
}

variable "cluster_viewer_role_arn" {
  description = "IAM Role ARN for EKS cluster view-only access entry"
  type        = string
  default     = "arn:aws:iam::<account_id>:role/aws-reserved/sso.amazonaws.com/ap-northeast-2/AWSReservedSSO_<role_name>_<role_id>"
}

variable "cluster_addons" {
  description = "EKS cluster addons and their versions"
  type = map(object({
    addon_version = string
  }))

  default = {
    "vpc-cni" = {
      addon_version               = "v1.20.3-eksbuild.1"
      resolve_conflicts_on_create = "OVERWRITE"
    }
    "kube-proxy" = {
      addon_version               = "v1.34.0-eksbuild.4"
      resolve_conflicts_on_create = "OVERWRITE"
    }
    "coredns" = {
      addon_version               = "v1.12.4-eksbuild.1"
      resolve_conflicts_on_create = "OVERWRITE"
    }
  }
}

variable "node_instance_types" {
  description = "Instance types for the self-managed worker node group"
  type        = list(string)
  default     = ["m5.xlarge"]
}

variable "node_min_size" {
  description = "Minimum number of worker nodes in the self-managed node group"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes in the self-managed node group"
  type        = number
  default     = 10
}

variable "node_desired_size" {
  description = "Desired number of worker nodes in the self-managed node group"
  type        = number
  default     = 2
}

variable "node_disk_size" {
  description = "Disk size in GiB for worker nodes in the self-managed node group"
  type        = number
  default     = 100
}

variable "node_ami_id" {
  description = "Custom AMI ID for the self-managed worker node group (if null, EKS-optimized default is used)"
  type        = string
  default     = null
}

variable "use_custom_launch_template" {
  description = "Whether to use a custom launch template for the self-managed node group"
  type        = bool
  default     = false
}

variable "node_launch_template_id" {
  description = "ID of the custom launch template to use when use_custom_launch_template is true"
  type        = string
  default     = null
}

variable "alb_allowed_cidrs" {
  description = "List of CIDR blocks allowed to access the public ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "additional_cluster_tags" {
  description = "Additional tags to apply to the EKS cluster and its resources"
  type        = map(string)
  default     = {}
}
