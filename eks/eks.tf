module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31.6"

  cluster_name    = var.cluster-name
  cluster_version = var.cluster-version
  cluster_addons  = var.cluster-addons
  create_iam_role = false
  iam_role_arn    = aws_iam_role.eks-master.arn

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  vpc_id                   = local.vpc-id
  subnet_ids               = local.private-subnets-ids

  eks_managed_node_group_defaults = {
    ami_type       = "AL2023_x86_64_STANDARD"
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
    disk_size      = 50
  }

  eks_managed_node_groups = {
    node = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.xlarge"]

      min_size     = 2
      max_size     = 10
      desired_size = 2
      disk_size    = 100
      use_custom_launch_template = false
      create_iam_role            = false
      iam_role_arn = aws_iam_role.eks-worker.arn
    }
  }

  tags = {
    "Resource" : "eks"
    "k8s.io/cluster-autoscaler/enabled" : "true"
    "k8s.io/cluster-autoscaler/${var.cluster-name}" : "true"
  }
}