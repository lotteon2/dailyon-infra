provider "aws" {
  region = "ap-northeast-2"
}

data "aws_caller_identity" "current" {}

locals {
  vpc_name               = "dailyon_eks_cluster_vpc"
  vpc_cidr               = "192.168.0.0/16"
  azs                    = ["ap-northeast-2a", "ap-northeast-2c"]
  cluster_name           = "dailyon"
  cluster_version        = "1.27"
  iam_role_policy_prefix = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.vpc_name
  azs  = local.azs
  cidr = local.vpc_cidr

  # NAT게이트웨이를 생성합니다.
  enable_nat_gateway = true
  # NAT게이트웨이를 1개만 생성합니다.
  single_nat_gateway = true

  public_subnets = [
    for index in range(2) :
    cidrsubnet(local.vpc_cidr, 4, index)
  ]

  private_subnets = [
    for index in range(2) :
    cidrsubnet(local.vpc_cidr, 4, index + 2)
  ]
}

# Create Security Group
resource "aws_security_group" "dailyon_eks_cluster_sg" {
  name        = "dailyon_eks_cluster_sg"
  description = "Security Group for Dailyon EKS nodes"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

module "iam_policy_autoscaling" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = "${local.cluster_name}-cluster-autoscaler"
  path        = "/"
  description = "Autoscaling policy for cluster ${local.cluster_name}"

  policy = data.aws_iam_policy_document.worker_autoscaling.json
}

data "aws_iam_policy_document" "worker_autoscaling" {
  statement {
    sid    = "eksWorkerAutoscalingAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "eksWorkerAutoscalingOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${local.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}

# Create IAM role for EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "EKSClusterRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com",
        },
      },
    ],
  })
}

# Attach AmazonEKSClusterPolicy to the IAM role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Attach AmazonEKSVPCResourceController to the IAM role
resource "aws_iam_role_policy_attachment" "eks_vpc_controller_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

# eks module and node group
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  iam_role_arn = aws_iam_role.eks_cluster_role.arn

  eks_managed_node_group_defaults = {
    ami_type                     = "AL2_x86_64"
    disk_size                    = 10
    iam_role_additional_policies = {
      autoscaling = "${local.iam_role_policy_prefix}/${module.iam_policy_autoscaling.name}"
    }
  }

  eks_managed_node_groups = {

#    app1 = {
#      desired_size = 1
#      max_size     = 2
#      min_size     = 1
#
#      instance_types = ["t3.large"]
#      capacity_type  = "SPOT"
#
#      additional_security_group_ids = [aws_security_group.dailyon_eks_cluster_sg.id]
#
#      labels = {
#        type = "App"
#        size = "Large"
#      }
#
#      tags = {
#        "k8s.io/cluster-autoscaler/enabled" : "true"
#        "k8s.io/cluster-autoscaler/${local.cluster_name}" : "true"
#      }
#    }
#
#    app2 = {
#      desired_size = 1
#      max_size     = 2
#      min_size     = 1
#
#      instance_types = ["t3.medium"]
#      capacity_type  = "SPOT"
#
#      additional_security_group_ids = [aws_security_group.dailyon_eks_cluster_sg.id]
#
#      labels = {
#        type = "App"
#        size = "Medium"
#      }
#
#      tags = {
#        "k8s.io/cluster-autoscaler/enabled" : "true"
#        "k8s.io/cluster-autoscaler/${local.cluster_name}" : "true"
#      }
#    }

    util = {
      name = "util"

      desired_size = 1
      max_size     = 2
      min_size     = 1

      instance_types = ["t3.small"]
      capacity_type  = "SPOT"

      use_custom_launch_template = false

      remote_access = {
        ec2_ssh_key = "dailyon_eks_cluster_key"
        source_security_group_ids = [aws_security_group.dailyon_eks_cluster_sg.id]
      }

      labels = {
        type = "Util"
        size = "Small"
      }

      tags = {
        "k8s.io/cluster-autoscaler/enabled" : "true"
        "k8s.io/cluster-autoscaler/${local.cluster_name}" : "true"
      }
    }

#    kafka = {
#      desired_size = 1
#      max_size     = 2
#      min_size     = 1
#
#      instance_types = ["t3.large"]
#      capacity_type  = "SPOT"
#
#      additional_security_group_ids = [aws_security_group.dailyon_eks_cluster_sg.id]
#
#      labels = {
#        type = "Kafka"
#      }
#
#      tags = {
#        "k8s.io/cluster-autoscaler/enabled" : "true"
#        "k8s.io/cluster-autoscaler/${local.cluster_name}" : "true"
#      }
#    }
#
#    redis = {
#      desired_size = 1
#      max_size     = 2
#      min_size     = 1
#
#      instance_types = ["t3.large"]
#      capacity_type  = "SPOT"
#
#      additional_security_group_ids = [aws_security_group.dailyon_eks_cluster_sg.id]
#
#      labels = {
#        type = "Redis"
#      }
#
#      tags = {
#        "k8s.io/cluster-autoscaler/enabled" : "true"
#        "k8s.io/cluster-autoscaler/${local.cluster_name}" : "true"
#      }
#    }
  }

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}