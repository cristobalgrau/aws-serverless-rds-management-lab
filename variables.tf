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