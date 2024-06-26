# Secrets Managerからシークレットを取得
data "aws_secretsmanager_secret" "rds" {
  name = var.secret_name
}

data "aws_secretsmanager_secret_version" "rds" {
  secret_id = data.aws_secretsmanager_secret.rds.id
}

# シークレットの値をjsondecodeして利用
locals {
  secret = jsondecode(data.aws_secretsmanager_secret_version.rds.secret_string)
}

resource "aws_db_instance" "mariadb" {
  identifier        = local.secret.dbInstanceIdentifier
  engine            = local.secret.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [var.security_group_id]


  username            = local.secret.username
  password            = local.secret.password
  db_name             = local.secret.dbname
  skip_final_snapshot = true
  multi_az            = true

  tags = {
    Name = "Tokyo MariaDB"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = var.subnet_ids
  tags = {
    Name = "My DB Subnet Group"
  }
}
