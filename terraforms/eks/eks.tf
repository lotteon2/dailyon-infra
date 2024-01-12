provider "aws" {
  region = "ap-northeast-2"
}

locals {
  cluster_name = "dailyon"

  vpc_id     = module.vpc.vpc_id
  vpc_name   = "dailyon_eks_cluster_vpc"
  vpc_cidr   = "192.168.0.0/16"
  azs        = ["ap-northeast-2a", "ap-northeast-2c"]
  subnet_ids = module.vpc.public_subnets

  external_dns_arn  = var.external_dns_arn  # 개인용 Route53 HostingZone
  external_cert_arn = var.external_cert_arn

  tags = {
    CreatedBy = "Terraform"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.vpc_name
  azs  = local.azs
  cidr = local.vpc_cidr

  # NAT게이트웨이를 생성합니다.
  enable_nat_gateway = false

  enable_dns_support      = true
  enable_dns_hostnames    = true
  map_public_ip_on_launch = true # 퍼블릭 서브넷 내 생성되는 리소스에 자동으로 퍼블릭 IP를 할당한다.

  public_subnets = [
    for index in range(2) :
    cidrsubnet(local.vpc_cidr, 4, index)
  ]

  private_subnets = [
    for index in range(2) :
    cidrsubnet(local.vpc_cidr, 4, index + 2)
  ]

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1 # 해당 태그 지정 시, k8s 내에서 ingress 생성 시 서브넷 자동 지정
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

# Terraform에서 k8s에 접근할 수 있도록 인증 정보를 제공한다.
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks.token
}
# Terraform에서 helm을 통해 k8s 내 Add-on를 설치할 수 있도록 인증 정보를 제공한다.
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

data "aws_availability_zones" "available" {}

# Terraform에서 AWS의 계정 ID를 참조하기 위해 정의한다. 사용은 ${data.aws_caller_identity.current.account_id}
data "aws_caller_identity" "current" {}

# EKS 클러스터와 통신하기 위한 인증 토큰을 가져온다.
data "aws_eks_cluster_auth" "eks" { name = module.eks.cluster_name }

################################################################################
### EKS Module
################################################################################
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                   = local.cluster_name
  cluster_version                = 1.27
  cluster_endpoint_public_access = true

  # EKS Add-On 정의
  cluster_addons = {
    coredns = {
      most_recent       = true
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent              = true
      before_compute           = true  # 워커 노드가 프로비저닝되기 전 vpc-cni가 배포되어야한다. 배포 전 워커 노드가 프로비저닝 되면 파드 IP 할당 이슈 발생
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.vpc_cni_irsa_role.iam_role_arn  # IRSA(k8s ServiceAccount에 IAM 역할을 사용한다)
      configuration_values     = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"  # prefix assignment mode 활성화
          WARM_PREFIX_TARGET       = "1"  # 기본 권장 값
        }
      })
    }

    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
  }

  vpc_id     = local.vpc_id
  subnet_ids = local.subnet_ids

  # aws-auth configmap
  manage_aws_auth_configmap = true  # AWS -> EKS 접근을위한 configmap 자동 생성

  # 관리형 노드그룹에 사용할 공통 사항 정의
  eks_managed_node_group_defaults = {
    ami_type                   = "AL2_x86_64"
    capacity_type              = "SPOT"
    iam_role_attach_cni_policy = true
    use_name_prefix            = false  # false하지 않으면 리소스 이름 뒤 임의의 난수값이 추가되어 생성됨
    use_custom_launch_template = false  # AWS EKS 관리 노드 그룹에서 제공하는 기본 템플릿을 사용
    block_device_mappings      = {
      xvda = {
        device_name = "/dev/xvda"
        ebs         = {
          volume_size           = 20
          volume_type           = "gp3"
          delete_on_termination = true
        }
      }
    }
    remote_access = {
      # Remote access cannot be specified with a launch template
      ec2_ssh_key               = module.key_pair.key_pair_name
      source_security_group_ids = [aws_security_group.remote_access.id]
      tags                      = {
        "kubernetes.io/cluster/devops-eks-cluster" = "owned"  # AWS LB Controller 사용을 위한 요구 사항
      }
    }

    tags = local.tags
  }

  # 관리형 노드 그룹 정의
  eks_managed_node_groups = {

    app1 = {
      desired_size = 1
      max_size     = 2
      min_size     = 1

      instance_types = ["t3.large"]

      labels = {
        type = "App"
        size = "Large"
      }
    }

    app2 = {
      desired_size = 1
      max_size     = 2
      min_size     = 1

      instance_types = ["t3.large"]

      labels = {
        type = "App"
        size = "Large"
      }
    }

    app3 = {
      desired_size = 1
      max_size     = 2
      min_size     = 1

      instance_types = ["t3.medium"]

      labels = {
        type = "App"
        size = "Medium"
      }
    }

    db1 = {
      desired_size = 1
      max_size     = 2
      min_size     = 1

      instance_types = ["t3.large"]

      labels = {
        type = "Database"
        size = "Large"
      }
    }

    db2 = {
      desired_size = 1
      max_size     = 2
      min_size     = 1

      instance_types = ["t3.medium"]

      labels = {
        type = "Database"
        size = "Medium"
      }
    }

    util = {
      name = "util"

      desired_size = 1
      max_size     = 2
      min_size     = 1

      instance_types = ["t3.medium"]

      labels = {
        type = "Util"
        size = "Medium"
      }
    }

    kafka = {
      desired_size = 1
      max_size     = 2
      min_size     = 1

      instance_types = ["t3.medium"]

      labels = {
        type = "Kafka"
      }
    }

    redis = {
      desired_size = 1
      max_size     = 2
      min_size     = 1

      instance_types = ["t3.medium"]

      labels = {
        type = "Redis"
      }
    }
  }
}

# 각종 Add-on에 필요한 IRSA 생성해주는 모듈
module "vpc_cni_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "${local.cluster_name}-vpc-cni-irsa-role"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = local.tags
}

module "load_balancer_controller_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = "${local.cluster_name}-lb-controller-irsa-role"
  attach_load_balancer_controller_policy = true  # 이 Input을 기준으로 목적에 맞는 Role이 생성됨.

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = local.tags
}

module "load_balancer_controller_targetgroup_binding_only_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                                                       = "${local.cluster_name}-lb-controller-tg-binding-only-irsa-role"
  attach_load_balancer_controller_targetgroup_binding_only_policy = true  # 이 Input을 기준으로 목적에 맞는 Role이 생성됨.

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = local.tags
}

module "external_dns_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                     = "${local.cluster_name}-externaldns-irsa-role"
  attach_external_dns_policy    = true  # 이 Input을 기준으로 목적에 맞는 Role이 생성됨.
  external_dns_hosted_zone_arns = [local.external_dns_arn]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:external-dns"]
    }
  }

  tags = local.tags
}


module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "~> 2.0"

  key_name_prefix    = "devops-eks-cluster"
  create_private_key = true
}

resource "aws_security_group" "remote_access" {
  name_prefix = "${local.cluster_name}-cluster-remote-access"
  description = "Allow remote SSH access"
  vpc_id      = local.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Prometheus Port 9090 access"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Grafana Port 3000 access"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Zipkin Port 9411 access"
    from_port   = 9411
    to_port     = 9411
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "kubernetes_service_account" "aws-load-balancer-controller" {
  metadata {
    name        = "aws-load-balancer-controller"
    namespace   = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.load_balancer_controller_irsa_role.iam_role_arn
      # irsa 생성 모듈에서 output으로 iam_role_arn을 제공한다.
    }

    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
    }

  }

  depends_on = [module.load_balancer_controller_irsa_role]
}

resource "kubernetes_service_account" "external-dns" {
  metadata {
    name        = "external-dns"
    namespace   = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.external_dns_irsa_role.iam_role_arn
    }
  }

  depends_on = [module.external_dns_irsa_role]
}

### Helm
resource "helm_release" "aws-load-balancer-controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }
  set {
    name  = "serviceAccount.create"
    value = false
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  #depends_on = [kubernetes_service_account.aws-load-balancer-controller]
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  namespace  = "kube-system"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  wait       = false  ## 서비스가 완전히 올라올때 까지 대기
  set {
    name  = "provider"
    value = "aws"
  }
  set {
    name  = "serviceAccount.create"
    value = false
  }
  set {
    name  = "serviceAccount.name"
    value = "external-dns"
  }
  set {
    name  = "policy"
    value = "sync"
  }
}

module "ebs_csi_irsa_role" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name             = "AmazonEKS_EBS_CSI_DriverRole"
  attach_ebs_csi_policy = true
  oidc_providers        = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}
