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
      addon_version               = "v1.21.1-eksbuild.1"
      resolve_conflicts_on_create = "OVERWRITE"
    }
    "kube-proxy" = {
      addon_version               = "v1.34.1-eksbuild.2"
      resolve_conflicts_on_create = "OVERWRITE"
    }
    "coredns" = {
      addon_version               = "v1.12.4-eksbuild.6"
      resolve_conflicts_on_create = "OVERWRITE"
    }
    "aws-ebs-csi-driver" = {
      addon_version               = "v1.54.0-eksbuild.1"
      resolve_conflicts_on_create = "OVERWRITE"
    }
  }
}

variable "node_instance_types" {
  description = "Instance types for the self-managed worker node group (used in mixed_instances_policy)"
  type        = list(string)
  default     = ["m5.xlarge", "m5a.xlarge", "m5d.xlarge"]
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

variable "additional_cluster_tags" {
  description = "Additional tags to apply to the EKS cluster and its resources"
  type        = map(string)
  default     = {}
}

variable "mixed_instances_on_demand_base_capacity" {
  description = "Minimum number of on-demand instances to maintain for stability"
  type        = number
  default     = 1
}

variable "mixed_instances_on_demand_percentage" {
  description = "Percentage of on-demand instances above base capacity (0-100)"
  type        = number
  default     = 50
  validation {
    condition     = var.mixed_instances_on_demand_percentage >= 0 && var.mixed_instances_on_demand_percentage <= 100
    error_message = "On-demand percentage must be between 0 and 100."
  }
}

variable "mixed_instances_spot_pools" {
  description = "Number of Spot instance pools to use (1-20). More pools increase availability but may increase cost."
  type        = number
  default     = 4
  validation {
    condition     = var.mixed_instances_spot_pools >= 1 && var.mixed_instances_spot_pools <= 20
    error_message = "Spot pools must be between 1 and 20."
  }
}

variable "mixed_instances_spot_max_price" {
  description = "Maximum price per hour for Spot instances (empty string = on-demand price)"
  type        = string
  default     = ""
}

variable "mixed_instances_weights" {
  description = "Weighted capacity for each instance type in mixed_instances_policy. Key is instance type, value is weight."
  type        = map(number)
  default = {
    # 기본값: 모든 인스턴스 타입에 동일한 가중치 (1)
    # 예: "m5.xlarge" = 1, "m5a.xlarge" = 1, "m5d.xlarge" = 1
  }
}
