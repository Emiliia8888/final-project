resource "aws_db_parameter_group" "this" {
  count = var.use_aurora ? 0 : 1

  name   = "${var.name}-parameter-group"
  family = var.engine == "postgres" || var.engine == "aurora-postgresql" ? "postgres16" : "${var.engine}${replace(var.engine_version, ".", "")}"

  tags = {
    Name = "${var.name}-parameter-group"
  }

  parameter {
    name         = "log_statement"
    value        = "all"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "max_connections"
    value        = "200"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "work_mem"
    value        = "4096"
    apply_method = "immediate"
  }
}

resource "aws_rds_cluster_parameter_group" "this" {
  count = var.use_aurora ? 1 : 0

  name   = "${var.name}-cluster-params"
  family = var.engine == "postgres" || var.engine == "aurora-postgresql" ? "postgres16" : "${var.engine}${replace(var.engine_version, ".", "")}"

  tags = {
    Name = "${var.name}-cluster-params"
  }

  parameter {
    name         = "max_connections"
    value        = "200"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "log_statement"
    value        = "all"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "work_mem"
    value        = "4096"
    apply_method = "immediate"
  }
}
resource "aws_db_parameter_group" "aurora_instance" {
  count = var.use_aurora ? 1 : 0

  name   = "${var.name}-aurora-instance-params"
  family = var.engine == "postgres" || var.engine == "aurora-postgresql" ? "postgres16" : "${var.engine}${replace(var.engine_version, ".", "")}"

  tags = {
    Name = "${var.name}-aurora-instance-params"
  }

  parameter {
    name         = "log_statement"
    value        = "all"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "max_connections"
    value        = "200"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "work_mem"
    value        = "4096"
    apply_method = "immediate"
  }
}
