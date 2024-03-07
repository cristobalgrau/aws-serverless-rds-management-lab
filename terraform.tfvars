aws-region = "us-east-1"
vpc-name   = "RDS-project"
vpc-cidr   = "10.0.0.0/24"
private-subnets = {
  "private-subnet-1" = 1
  "private-subnet-2" = 2
}
public-subnets = {
  "public-subnet-1" = 1
  "public-subnet-2" = 2
}
private-lambda-name    = "RDS-private-lambda"
public-lambda-name     = "RDS-public-lambda"
private-db-subnet-name = "rds-private-subnet"
public-db-subnet-name  = "rds-public-subnet"
rds-private-db-name    = "rds-db-private"
rds-public-db-name     = "rds-db-public"
db-name                = "rds_db"
db-username            = "admin"
