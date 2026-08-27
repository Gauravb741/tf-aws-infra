output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "Public subnet ID."
  value       = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  description = "Private subnet ID."
  value       = module.vpc.private_subnet_id
}

output "security_group_id" {
  description = "EC2 security group ID."
  value       = module.security.ec2_security_group_id
}

output "instance_id" {
  description = "EC2 instance ID."
  value       = module.ec2.instance_id
}

output "instance_public_ip" {
  description = "EC2 public IP address."
  value       = module.ec2.instance_public_ip
}

output "application_url" {
  description = "Application URL."
  value       = "http://${module.ec2.instance_public_ip}:${var.application_port}"
}

output "health_check_url" {
  description = "Application health check URL."
  value       = "http://${module.ec2.instance_public_ip}:${var.application_port}/health"
}

output "cloudwatch_dashboard" {
  description = "CloudWatch dashboard URL."
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${module.monitoring.dashboard_name}"
}

output "ami_id" {
  description = "AMI ID used."
  value       = module.ec2.ami_id
}