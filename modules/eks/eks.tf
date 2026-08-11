
module "aws_eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                  = "dev-eks-cluster"
  cluster_version               = "1.36"
  bootstrap_self_managed_addons = false

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  vpc_id     = var.vpc_id
  subnet_ids = var.subnets

  include_oidc_root_ca_thumbprint = false

  custom_oidc_thumbprints = [
    "06b25927c42a721631c1efd9431e648fa62e1e39"
  ]

  #
  # Existing cluster IAM role
  #

  create_iam_role = false

  iam_role_arn = "arn:aws:iam::034255117140:role/eks-cluster-role-lesson-7"

  #
  # Existing KMS key
  #

  create_kms_key = false

  cluster_encryption_config = {
    resources = ["secrets"]

    provider_key_arn = "arn:aws:kms:eu-central-1:034255117140:key/04d02d5e-5057-4698-80d0-d6ea44874a71"
  }

  #
  # Existing cluster security group
  #

  create_cluster_security_group = false

  cluster_security_group_id = ""

  #
  # Existing node security group
  #

  create_node_security_group = false

  node_security_group_id = "sg-01ba2c0d2024f79b7"

  #
  # Existing node group
  #

  eks_managed_node_groups = {
    main = {
      name            = "dev-node-group"
      use_name_prefix = false

      min_size     = 2
      max_size     = 6
      desired_size = 2

      instance_types = [
        "t3.medium"
      ]

tags = {
  Name = "dev-node-group"
}

      subnet_ids = var.subnets

      create_iam_role = false

      iam_role_arn = "arn:aws:iam::034255117140:role/eks-node-role-lesson-7"

      use_custom_launch_template = false

      vpc_security_group_ids = [
        "sg-01ba2c0d2024f79b7"
      ]
    }
  }

  enable_cluster_creator_admin_permissions = false
}
