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
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"

    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name,
      "--region",
      var.aws_region
    ]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"

      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name,
        "--region",
        var.aws_region
      ]
    }
  }
}

module "vpc" {
  source = "./modules/vpc"
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

module "monitoring" {
  source = "./modules/monitoring"

  depends_on = [
    module.eks
  ]
}

module "jenkins" {
  source = "./modules/jenkins"

  depends_on = [
    module.eks
  ]
}

module "argo_cd" {
  source = "./modules/argo_cd"

  depends_on = [
    module.eks
  ]
}

module "aws_load_balancer_controller" {
  source = "./modules/aws_load_balancer_controller"

  cluster_name = module.eks.cluster_name
  vpc_id       = module.vpc.vpc_id
  oidc_issuer  = module.eks.cluster_oidc_issuer

  depends_on = [
    module.eks,
    module.vpc
  ]
}

module "rds" {
  source      = "./modules/rds"
  environment = var.environment
  name        = "django-db"

  use_aurora = false

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  db_name  = "django"
  username = "django_admin"
  password = var.db_password

  engine_version         = "16"
  instance_class         = "db.t3.micro"
  parameter_group_family = "postgres16"

  depends_on = [
    module.vpc
  ]
}

module "s3_backend" {
  source = "./modules/s3-backend"

  bucket_name = "emiliia-ft-state-lesson-99"
}
