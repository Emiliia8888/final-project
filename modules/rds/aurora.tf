resource "aws_rds_cluster" "this" {

  count = var.use_aurora ? 1 : 0


  cluster_identifier = "${var.name}-cluster"


  engine = var.engine

  engine_version = var.engine_version


  database_name = var.database_name

  master_username = var.username

  master_password = var.password


  db_subnet_group_name = aws_db_subnet_group.this.name


  vpc_security_group_ids = [
    aws_security_group.this.id
  ]


  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this[0].name


  skip_final_snapshot = true


  tags = {
    Name = "${var.name}-cluster"
  }
}



resource "aws_rds_cluster_instance" "writer" {

  count = var.use_aurora ? 1 : 0


  identifier = "${var.name}-writer"


  cluster_identifier = aws_rds_cluster.this[0].id


  engine = aws_rds_cluster.this[0].engine


  engine_version = aws_rds_cluster.this[0].engine_version


  instance_class = var.instance_class


  db_parameter_group_name = aws_db_parameter_group.aurora_instance[0].name


}