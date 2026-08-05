output "endpoint" {

  value = var.use_aurora ? aws_rds_cluster.this[0].endpoint : aws_db_instance.this[0].endpoint

}


output "database_security_group_id" {

  value = aws_security_group.this.id

}


output "subnet_group_name" {

  value = aws_db_subnet_group.this.name

}


output "cluster_id" {

  value = var.use_aurora ? aws_rds_cluster.this[0].id : null

}