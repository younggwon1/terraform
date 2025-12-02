## eks master
resource "aws_iam_role" "eks-master" {
  name = "${var.cluster_name}-master"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-master-cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-master.name
}

resource "aws_iam_role_policy_attachment" "eks-master-service" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-master.name
}

## eks node
resource "aws_iam_role" "eks-worker" {
  name = "${var.cluster_name}-worker"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-worker-node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-worker.name
}

resource "aws_iam_role_policy_attachment" "eks-worker-cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-worker.name
}

resource "aws_iam_role_policy_attachment" "eks-worker-ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = aws_iam_role.eks-worker.name
}

resource "aws_iam_role_policy_attachment" "eks-worker-ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks-worker.name
}

## cluster autoscaler
resource "aws_iam_role" "eks-worker-autoscaler" {
  name = "${var.cluster_name}-autoscaler"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.eks.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${trimprefix(module.eks.oidc_provider, "https://")}:sub": [
            "system:serviceaccount:kube-system:cluster-autoscaler-service"
          ]
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "eks-worker-autoscaler" {
  name = "${var.cluster_name}-autoscaler"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeScalingActivities",
        "autoscaling:DescribeTags",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplateVersions"
      ],
      "Resource": ["*"],
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}" : "owned",
          "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled" : "true"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeImages",
        "ec2:GetInstanceTypesFromInstanceRequirements",
        "eks:DescribeNodegroup"
      ],
      "Resource": ["*"],
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}" : "owned",
          "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled" : "true"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-worker-autoscaler" {
  policy_arn = aws_iam_policy.eks-worker-autoscaler.arn
  role       = aws_iam_role.eks-worker-autoscaler.name
}

## OIDC
data "tls_certificate" "eks" {
  url = module.eks.oidc_provider
}

resource "aws_iam_openid_connect_provider" "eks" {
  url            = module.eks.oidc_provider
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    data.tls_certificate.eks.certificates[0].sha1_fingerprint
  ]
}
