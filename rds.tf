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
  password                = var.db_pass
  parameter_group_name    = "default.mysql8.0"
  skip_final_snapshot     = true
  backup_retention_period = 0
  db_subnet_group_name    = aws_db_subnet_group.private-db-subnet.name
  vpc_security_group_ids  = [aws_security_group.allow-lambda-to-rds.id]
}

# Create Security Group to allow traffic from Lamda to RDS
resource "aws_security_group" "allow-lambda-to-rds" {
  name        = "rds-lambda-connect"
  description = "Allow inbound traffic from lambda"
  vpc_id      = aws_vpc.vpc.id
}

# Created ingress rule for all traffic from Lambda to RDS
resource "aws_vpc_security_group_ingress_rule" "allow-lambda-to-rds" {
  security_group_id            = aws_security_group.allow-lambda-to-rds.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.allow-rds-to-lambda.id
}

# Create RDS Public
resource "aws_db_instance" "rds-public" {
  allocated_storage       = 20
  db_name                 = var.db-name
  identifier              = var.rds-public-db-name
  engine                  = "mysql"
  engine_version          = "8.0.35"
  instance_class          = "db.t3.micro"
  username                = var.db-username
  password                = var.db_pass
  parameter_group_name    = "default.mysql8.0"
  skip_final_snapshot     = true
  publicly_accessible     = true
  backup_retention_period = 0
  db_subnet_group_name    = aws_db_subnet_group.public-db-subnet.name
  vpc_security_group_ids  = [aws_security_group.allow-all-traffic.id]
}