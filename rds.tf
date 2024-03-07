# ==== RDS SECTION ====

# Create DB Subnet Group for Private and Private subnets
resource "aws_db_subnet_group" "private-db-subnet" {
  name        = var.private-db-subnet-name
  subnet_ids  = [for subnet_key, subnet_value in aws_subnet.private_subnets : subnet_value.id]
  description = "DB subnet for the RDS Private"
}

resource "aws_db_subnet_group" "public-db-subnet" {
  name        = var.public-db-subnet-name
  subnet_ids  = [for subnet_key, subnet_value in aws_subnet.public_subnets : subnet_value.id]
  description = "DB subnet for the RDS Public"
}

# Create RDS Private
resource "aws_db_instance" "rds-private" {
  allocated_storage       = 20
  db_name                 = var.db-name
  identifier              = var.rds-private-db-name
  engine                  = "mysql"
  engine_version          = "8.0.35"
  instance_class          = "db.t3.micro"
  username                = var.db-username
  password                = var.db_pass   #hot to use ENV VARS from shell: https://support.hashicorp.com/hc/en-us/articles/4547786359571-Reading-and-using-environment-variables-in-Terraform-runs
  parameter_group_name    = "default.mysql8.0"
  skip_final_snapshot     = true
  backup_retention_period = 0
  db_subnet_group_name    = aws_db_subnet_group.private-db-subnet.name
}

# resource "aws_db_instance" "rds-private" {
#   db_name = "rds-db-private"
#   instance_class = "db.t3.micro"
# }
