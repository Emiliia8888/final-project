# Django GitOps Project

## Phase 2 Hardening Updates

Implemented improvements after architecture review.

## Terraform

- Removed obsolete EKS data source dependencies from configuration.
- Connected RDS module with VPC outputs:
  - VPC ID
  - private subnets
- Completed S3 backend module:
  - S3 state bucket
  - bucket versioning
  - server-side encryption
  - public access blocking
  - DynamoDB state locking
- EKS module uses `terraform-aws-modules/eks/aws` without custom hardcoded:
  - IAM roles
  - KMS keys
  - security groups

## Kubernetes / Helm

- Migrated Jenkins from Kubernetes resources to Helm release.
- Configured Jenkins LoadBalancer service with NLB annotation.
- Updated Django Helm chart:
  - ConfigMap integration
  - Secret integration
  - environment configuration
- Added namespace dependencies:
  - monitoring namespace for kube-prometheus-stack
  - kube-system usage for AWS Load Balancer Controller

## Validation

Verified configuration:

```bash
terraform validate
