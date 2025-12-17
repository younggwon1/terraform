resource "aws_security_group" "eks_worker" {
  name        = "${var.cluster_name}-worker-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = local.vpc_id

  ingress {
    description = "Allow inbound traffic from worker nodes"
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    self        = true
  }

  # VPC 내부 통신 (RDS, MSK 등)
  egress {
    description = "Allow outbound to VPC internal services"
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = [
      local.vpc_cidr_block
    ]
  }

  # 외부 통신 (제휴사 / 인터넷)
  egress {
    description = "Allow outbound HTTPS via NAT Gateway only"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.nat_gateway_cidrs
  }

  tags = {
    Name                                        = "${var.cluster_name}-worker-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "eks_cluster_to_worker" {
  description              = "Allow inbound traffic from EKS cluster to worker nodes"
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = module.eks.cluster_security_group_id
  security_group_id        = aws_security_group.eks_worker.id
}

resource "aws_security_group_rule" "worker_to_eks_cluster" {
  description              = "Allow inbound traffic from worker nodes to EKS cluster"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_worker.id
  security_group_id        = module.eks.cluster_security_group_id
}
