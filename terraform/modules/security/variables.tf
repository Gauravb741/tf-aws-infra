variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, prod)."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the security group will be created."
  type        = string
}

variable "application_port" {
  description = "Port the application listens on."
  type        = number
  default     = 5000
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into EC2 instances. Use your IP, not 0.0.0.0/0."
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}