variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}
variable "aws_profile" {
  description = "AWS profile to use for authentication"
  type        = string
}
#network
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}
variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}
variable "public_subnet_1_cidr" {
  description = "CIDR block for the first public subnet"
  type        = string
}
variable "public_subnet_2_cidr" {
  description = "CIDR block for the second public subnet"
  type        = string
}
variable "private_app_subnet_cidr" {
  description = "CIDR block for the private application subnet"
  type        = string
}
variable "private_db_subnet_cidr" {
  description = "CIDR block for the private database subnet"
  type        = string
}
#data base pass
variable "db_password" {
  type      = string
  sensitive = true
  ephemeral = true
}