module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.10.1"

  vpc_id              = local.vpc_id
  subnet_ids          = local.private_subnets_ids
  name                = var.cluster_name
  kubernetes_version  = var.cluster_version
  addons              = var.cluster_addons
  deletion_protection = true

  create_iam_role = false
  iam_role_arn    = aws_iam_role.eks-master.arn

  endpoint_public_access  = var.endpoint_public_access
  endpoint_private_access = var.endpoint_private_access

  self_managed_node_groups = {
    node = {
      create_iam_role            = false
      iam_role_arn               = aws_iam_role.eks-worker.arn
      use_custom_launch_template = true
      launch_template_id         = aws_launch_template.eks_worker.id
      launch_template_version    = "$Latest"

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      mixed_instances_policy = {
        launch_template = {
          launch_template_specification = {
            launch_template_id = aws_launch_template.eks_worker.id
            version            = "$Latest"
          }

          override = [
            for instance_type in var.node_instance_types : {
              instance_type     = instance_type
              weighted_capacity = lookup(var.mixed_instances_weights, instance_type, 1)
            }
          ]
        }

        # 인스턴스 분배 전략
        instances_distribution = {
          # 온디맨드 기본 용량 (최소한 이만큼은 온디맨드로 유지하여 안정성 확보)
          on_demand_base_capacity = var.mixed_instances_on_demand_base_capacity
          # 기본 용량 초과 시 온디맨드 비율 (나머지는 스팟 인스턴스 사용)
          on_demand_percentage_above_base_capacity = var.mixed_instances_on_demand_percentage
          # 스팟 인스턴스 할당 전략: capacity-optimized (가용성 최적화)
          spot_allocation_strategy = "capacity-optimized"
          # 스팟 인스턴스 풀 수 (더 많은 풀에서 선택하여 가용성 향상)
          spot_instance_pools = var.mixed_instances_spot_pools
          # 스팟 최대 가격 (빈 문자열이면 null로 설정하여 온디맨드 가격 사용)
          spot_max_price = var.mixed_instances_spot_max_price != "" ? var.mixed_instances_spot_max_price : null
        }
      }

      tags = {
        "Name"                                          = "${var.cluster_name}-node-group"
        "kubernetes.io/cluster/${var.cluster_name}"     = "owned"
        "k8s.io/cluster-autoscaler/enabled"             = "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
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
