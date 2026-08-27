variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, prod)."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "instance_id" {
  description = "ID of the EC2 instance to monitor."
  type        = string
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization percentage that triggers the high CPU alarm."
  type        = number
  default     = 80
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}