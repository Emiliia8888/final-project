# AWS Terraform EKS Final Project

## Project Overview

This project demonstrates a complete DevOps workflow for deploying a Django application on AWS using Infrastructure as Code, Kubernetes, CI/CD and GitOps practices.

The infrastructure is fully managed with Terraform and deployed on Amazon EKS.

The project includes:

* AWS VPC networking
* Amazon EKS Kubernetes cluster
* Managed Node Group
* Amazon RDS database
* Amazon ECR container registry
* Jenkins CI pipeline
* ArgoCD GitOps deployment
* AWS Load Balancer Controller
* Kubernetes manifests and Helm charts

## Architecture

```
GitHub
   |
   v
Jenkins Pipeline
   |
   v
Docker Build
   |
   v
Amazon ECR
   |
   v
ArgoCD GitOps
   |
   v
Amazon EKS
   |
   v
Django Application
```

## Technologies

| Component              | Technology            |
| ---------------------- | --------------------- |
| Cloud Provider         | AWS                   |
| Infrastructure as Code | Terraform             |
| Container Platform     | Kubernetes            |
| Kubernetes Service     | Amazon EKS            |
| CI/CD                  | Jenkins               |
| GitOps                 | ArgoCD                |
| Container Registry     | Amazon ECR            |
| Database               | Amazon RDS PostgreSQL |
| Package Management     | Helm                  |
| Application            | Django                |

## AWS Infrastructure

Region:

```
eu-central-1
```

EKS Cluster:

```
django-gitops-cluster
```

VPC:

```
vpc-0b54945bf169ee3e3
```

Infrastructure components:

* VPC
* Public and private subnets
* Internet Gateway
* NAT Gateway
* Security Groups
* EKS Cluster
* Managed Node Group
* IAM Roles
* OIDC Provider
* EBS CSI Driver
* RDS Database
* ECR Repository

## Terraform Structure

```
final-project/

├── main.tf
├── variables.tf
├── outputs.tf
├── backend.tf
├── Dockerfile
├── Jenkinsfile

├── modules/
│   ├── vpc
│   ├── eks
│   ├── rds
│   ├── ecr
│   ├── jenkins
│   ├── argo_cd
│   ├── aws_load_balancer_controller
│   └── s3-backend

├── charts/
│   └── django-app

└── k8s/
    ├── deployment.yaml
    └── service.yaml
```

Terraform state is stored remotely using AWS backend.

## CI/CD Pipeline

The deployment workflow:

```
GitHub
   |
   v
Jenkins
   |
   v
Docker Image Build
   |
   v
Push Image to Amazon ECR
   |
   v
ArgoCD detects changes
   |
   v
Deploy application to EKS
   |
   v
Django Application
```

## Jenkins

Jenkins is deployed inside Kubernetes and managed by Terraform.

Check Jenkins service:

```bash
kubectl get svc -n jenkins
```

Get initial password:

```bash
kubectl exec -it $(kubectl get pods -n jenkins -o jsonpath='{.items[0].metadata.name}') \
-n jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword
```

Default user:

```
admin
```

## ArgoCD

ArgoCD is used for GitOps-based Kubernetes deployments.

Check ArgoCD service:

```bash
kubectl get svc -n argocd
```

Get password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
-o jsonpath="{.data.password}" | base64 --decode; echo
```

Login:

```
username: admin
```

## Kubernetes Deployment

Application manifests:

```
k8s/

├── deployment.yaml
└── service.yaml
```

Helm chart:

```
charts/

└── django-app
```

## Apply Terraform Infrastructure

Initialize Terraform:

```bash
terraform init -upgrade
```

Deploy:

```bash
terraform apply
```

## Verify Deployment

Check Kubernetes resources:

```bash
kubectl get pods -A
```

Check application service:

```bash
kubectl get svc
```
## Security

Implemented security practices:

- Terraform state excluded from Git
- Sensitive files excluded using .gitignore
- Secrets are not stored in repository
- IAM roles configured
- Kubernetes RBAC configured

```markdown
Security verification:

```bash
git ls-files | grep -E "tfstate|tfvars|secret|key|pem|env"


## Screenshots

Screenshots location:

docs/screenshots/

Examples:

- eks.png
- jenkins.png
- argocd.png
- loadbalancer.png
- application.png

## Cleanup

Destroy infrastructure:

```bash
terraform destroy
```
## Future Improvements

- Add Prometheus and Grafana monitoring
- Add HTTPS with AWS Certificate Manager
- Add automated tests
- Add Kubernetes autoscaling


## Repository

GitHub:

https://github.com/Emiliia8888/final-project


## Author

DevOps Portfolio Project

Built with AWS + Terraform + Kubernetes + Jenkins + ArgoCD
