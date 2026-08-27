output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.app.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = aws_instance.app.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance."
  value       = aws_instance.app.private_ip
}

output "ami_id" {
  description = "AMI ID used by the EC2 instance."
  value       = data.aws_ami.amazon_linux_2023.id
}

output "iam_role_name" {
  description = "Name of the IAM role attached to the EC2 instance."
  value       = aws_iam_role.ec2.name
}

output "iam_role_arn" {
  description = "ARN of the IAM role attached to the EC2 instance."
  value       = aws_iam_role.ec2.arn
}