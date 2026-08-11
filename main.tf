
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.2"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "existing" {
  name = "dev-eks-cluster"
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.existing.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.existing.certificate_authority[0].data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"

      args = [
        "eks",
        "get-token",
        "--cluster-name",
        data.aws_eks_cluster.existing.name
      ]
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.existing.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.existing.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"

    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.aws_eks_cluster.existing.name
    ]
  }
}

module "vpc" {
  source = "./modules/vpc"
}


module "rds" {
  source = "./modules/rds"

  vpc_id          = var.rds_vpc_id
  private_subnets = var.rds_private_subnets

  use_aurora = false

  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t3.micro"
  multi_az       = false

  database_name   = "django"
  master_username = "django_admin"
  master_password = var.db_password
}

module "ecr" {
  source = "./modules/ecr"
}


module "eks" {
  source = "./modules/eks"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  depends_on = [
    module.vpc
  ]
}


module "jenkins" {
  source = "./modules/jenkins"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider

  depends_on = [
    module.eks
  ]
}


module "argo_cd" {
  source = "./modules/argo_cd"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  depends_on = [
    module.eks
  ]
}

module "aws_load_balancer_controller" {
  source = "./modules/aws_load_balancer_controller"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  cluster_name = module.eks.cluster_name
  vpc_id       = module.vpc.vpc_id

  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider

  depends_on = [
    module.eks
  ]
}

module "monitoring" {
  source = "./modules/monitoring"

  providers = {
    helm = helm
  }

  depends_on = [
    module.eks,
    module.aws_load_balancer_controller
  ]
}
