variable "aws-region" {
  description = "AWS Region to deploy the Infrastructure"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR used for the VPC"
  type        = string
}

variable "private_subnets" {
  description = "Private Subnets the code will create"
  type        = map(number)
}

variable "public_subnets" {
  description = "Public Subnets the code will create"
  type        = map(number)
}