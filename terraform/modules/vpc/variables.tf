variable "project_name" {
  description = "Name of the project, used as a prefix for all resource names."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, prod)."
  type        = string
}

variable "aws_region" {
  description = "AWS region where the VPC will be created."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (e.g. 10.0.0.0/16)."
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet (must be within vpc_cidr)."
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet (must be within vpc_cidr)."
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources created by this module."
  type        = map(string)
  default     = {}
}