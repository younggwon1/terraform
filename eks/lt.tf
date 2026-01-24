resource "aws_launch_template" "eks_worker" {
  name_prefix   = "${var.cluster_name}-worker-"
  description   = "Launch template for ${var.cluster_name} self-managed node group"
  image_id      = var.node_ami_id != null ? var.node_ami_id : data.aws_ami.eks_optimized[0].id
  instance_type = var.node_instance_types[0]
  ebs_optimized = true

  iam_instance_profile {
    name = aws_iam_instance_profile.eks-worker.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.eks_worker.id]
    delete_on_termination       = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type           = "gp3"
      volume_size           = var.node_disk_size
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      throughput            = 125
    }
  }

  user_data = base64encode(<<-EOT
---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  kubelet:
    config:
      shutdownGracePeriod: 30s
      shutdownGracePeriodCriticalPods: 10s
    flags:
      - "--node-labels=node.kubernetes.io/name=node"
EOT
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name                                            = "${var.cluster_name}-worker-node"
      "kubernetes.io/cluster/${var.cluster_name}"     = "owned"
      "k8s.io/cluster-autoscaler/enabled"             = "true"
      "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name                                        = "${var.cluster_name}-worker-volume"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  }

  tags = {
    Name                                        = "${var.cluster_name}-worker-launch-template"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  update_default_version = true
}

resource "aws_iam_instance_profile" "eks-worker" {
  name = "${var.cluster_name}-worker-instance-profile"
  role = aws_iam_role.eks-worker.name

  tags = {
    Name = "${var.cluster_name}-worker-instance-profile"
  }
}
