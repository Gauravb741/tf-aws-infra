variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, prod)."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type. t3.micro is free-tier eligible."
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "ID of the subnet where the EC2 instance will be launched."
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group to attach to the EC2 instance."
  type        = string
}

variable "key_pair_name" {
  description = "Name of the EC2 key pair for SSH access. Leave empty to disable SSH key login (use SSM instead)."
  type        = string
  default     = ""
}

variable "application_port" {
  description = "Port the application container listens on."
  type        = number
  default     = 5000
}

variable "docker_image" {
  description = "Docker image to deploy (e.g. your-dockerhub-username/devops-platform-app:1.0.0)."
  type        = string
}

variable "app_version" {
  description = "Application version label (passed to the container as an env var)."
  type        = string
  default     = "1.0.0"
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}