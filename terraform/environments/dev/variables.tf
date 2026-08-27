variable "project_name" {
  description = "Name of the project."
  type        = string
  default     = "devops-platform"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR block."
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR block."
  type        = string
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "application_port" {
  description = "Application port."
  type        = number
  default     = 5000
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH to EC2 instances."
  type        = string
  # Override this in terraform.tfvars — do not use 0.0.0.0/0
  default = "10.0.0.0/8"
}

variable "key_pair_name" {
  description = "EC2 key pair name for SSH access."
  type        = string
  default     = ""
}

variable "docker_image" {
  description = "Docker image to deploy."
  type        = string
}

variable "app_version" {
  description = "Application version."
  type        = string
  default     = "1.0.0"
}

variable "cpu_alarm_threshold" {
  description = "CPU % threshold for CloudWatch alarm."
  type        = number
  default     = 80
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 7
}locals.tf