variable "aws-region" {
  description = "AWS Region to deploy the Infrastructure"
  type        = string
}

variable "vpc-name" {
  description = "Name for VPC"
  type        = string
}

variable "vpc-cidr" {
  description = "CIDR used for the VPC"
  type        = string
}

variable "private-subnets" {
  description = "Private Subnets the code will create"
  type        = map(number)
}

variable "public-subnets" {
  description = "Public Subnets the code will create"
  type        = map(number)
}

variable "public-lambda-name" {
  description = "Name for the Public Lambda Function"
  type        = string
}

variable "private-lambda-name" {
  description = "Name for the Public Lambda Function"
  type        = string
}

variable "private-db-subnet-name" {
  description = "Name for the Private DB subnet group"
  type        = string
}

variable "public-db-subnet-name" {
  description = "Name for the Public DB subnet group"
  type        = string
}

variable "rds-private-db-name" {
  description = "Name for Private RDS database"
  type        = string
}

variable "rds-public-db-name" {
  description = "Name for Public RDS database"
  type        = string
}

variable "db-name" {
  description = "Name for the database"
  type        = string
}

variable "db-username" {
  description = "Admin Username for the database"
  type        = string
}

variable "db_pass" {
  description = "Admin password for the database. It will take this value from your shell ENV VARS"
  # how to use ENV VARS from shell: https://support.hashicorp.com/hc/en-us/articles/4547786359571-Reading-and-using-environment-variables-in-Terraform-runs
  type = string
}