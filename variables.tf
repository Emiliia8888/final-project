variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "rds_vpc_id" {
  description = "Existing VPC ID where RDS is running"
  type        = string
}

variable "rds_private_subnets" {
  description = "Existing private subnet IDs for RDS"
  type        = list(string)
}
