data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  cluster_name     = "opsfleet-eks"
  cluster_version  = "1.28"

  tags = {
    Environment = "dev"
    Example    = local.cluster_name
    GithubRepo = "skursadk/opsfleet"
    Terraform  = "sk-tf-states/opsfleet/eks"
  }
}

provider "aws" {
  profile = "personal-profile"
  region  = "us-east-1"
  default_tags {
    tags = local.tags
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

data "aws_ami" "eks_default_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-arm64-node-${local.cluster_version}-v*"]
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnets
  control_plane_subnet_ids = var.public_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6g.large"]
  }

  eks_managed_node_groups = {

    general = {
      ami_type       = "AL2_ARM_64"
      ami_id         = data.aws_ami.eks_default_arm.image_id
      min_size       = 1
      max_size       = 2
      desired_size   = 1

      instance_types = ["t4g.large"]

      iam_role_additional_policies = {
        additional   = aws_iam_policy.eks_node_additional_policy.arn
      }
      enable_bootstrap_user_data = true

    }
  }

  # aws-auth configmap
  manage_aws_auth_configmap = true
  
  aws_auth_users = var.aws_auth_users
  aws_auth_roles = var.aws_auth_roles
}