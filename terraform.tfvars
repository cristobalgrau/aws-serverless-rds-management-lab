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