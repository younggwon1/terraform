module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.10.1"

  vpc_id              = local.vpc_id
  subnet_ids          = local.private_subnets_ids
  name                = var.cluster_name
  kubernetes_version  = var.cluster_version
  addons              = var.cluster_addons
  deletion_protection = true
  create_iam_role     = false
  iam_role_arn        = aws_iam_role.eks-master.arn

  endpoint_public_access  = var.endpoint_public_access
  endpoint_private_access = var.endpoint_private_access

  self_managed_node_groups = {
    node = {
      ami_type                   = var.node_ami_id == null ? "AL2023_x86_64_STANDARD" : null
      ami_id                     = var.node_ami_id
      instance_types             = var.node_instance_types
      min_size                   = var.node_min_size
      max_size                   = var.node_max_size
      desired_size               = var.node_desired_size
      disk_size                  = var.node_disk_size
      use_custom_launch_template = var.use_custom_launch_template
      launch_template_id         = var.use_custom_launch_template ? var.node_launch_template_id : null
      create_iam_role            = false
      iam_role_arn               = aws_iam_role.eks-worker.arn
      cloudinit_pre_nodeadm = [
        {
          content_type = "application/node.eks.aws"
          content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              kubelet:
                config:
                  shutdownGracePeriod: 30s
                  shutdownGracePeriodCriticalPods: 10s
                flags:
                  - "--node-labels=node.kubernetes.io/name=node,..."
          EOT
        }
      ]
      tags = {
        "Name" = "eks-node-group"
      }
    }
  }

  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API_AND_CONFIG_MAP"
  access_entries = {
    cluster_admin = {
      type              = "STANDARD"
      kubernetes_groups = []
      principal_arn     = var.cluster_admin_role_arn
      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type       = "cluster"
            namespaces = []
          }
        }
      }
    }

    cluster_viewer = {
      type              = "STANDARD"
      kubernetes_groups = []
      principal_arn     = var.cluster_viewer_role_arn
      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            type       = "cluster"
            namespaces = []
          }
        }
      }
    }
  }

  tags = merge(
    {
      "Resource"                                      = "eks"
      "k8s.io/cluster-autoscaler/enabled"             = "true"
      "k8s.io/cluster-autoscaler/${var.cluster_name}" = "true"
    },
    var.additional_cluster_tags
  )
}
