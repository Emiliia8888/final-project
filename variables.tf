variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "rds_password" {
  description = "Master password for RDS instance"
  type        = string
  sensitive   = true
}
