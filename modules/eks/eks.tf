module "aws_eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "django-gitops-cluster"
  cluster_version = "1.30"

  cluster_endpoint_public_access = true

  # Existing EKS cluster security group
  create_cluster_security_group = false
  cluster_security_group_id     = null
  cluster_additional_security_group_ids = [
    "sg-075ac93fc2d305bee"
  ]

  # Use existing EKS cluster security group imported into Terraform state

  # Encrypt Kubernetes secrets in etcd using AWS KMS
  cluster_encryption_config = {
    resources = ["secrets"]
  }

  create_kms_key          = true
  enable_kms_key_rotation = true

  vpc_id     = var.vpc_id
  subnet_ids = var.subnets

  eks_managed_node_groups = {
    main = {
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = ["t3.medium"]
    }
  }

  enable_cluster_creator_admin_permissions = false
}
