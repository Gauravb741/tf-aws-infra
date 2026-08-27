# =============================================================================
# SECURITY MODULE
#
# Creates Security Groups that act as virtual firewalls for EC2 instances.
#
# Security Groups created:
#   1. ec2_sg  — attached to the EC2 instance
#
# Principle of least privilege is applied:
#   - Inbound SSH is restricted to the configured CIDR (not 0.0.0.0/0)
#   - Inbound application traffic is restricted to the application port only
#   - All outbound traffic is allowed (required for package downloads, AWS API)
# =============================================================================

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-${var.environment}-ec2-sg"
  description = "Security group for ${var.project_name} EC2 instance in ${var.environment}"
  vpc_id      = var.vpc_id

  # ------------------------------------------------------------------
  # Inbound: SSH
  # Restricted to the IP specified in allowed_ssh_cidr.
  # For production: set this to your office/home IP, not 0.0.0.0/0.
  # ------------------------------------------------------------------
  ingress {
    description = "SSH access from allowed CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # ------------------------------------------------------------------
  # Inbound: Application
  # Only the configured application port is open to the internet.
  # ------------------------------------------------------------------
  ingress {
    description = "Application port"
    from_port   = var.application_port
    to_port     = var.application_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ------------------------------------------------------------------
  # Outbound: All traffic
  # Needed for: apt-get, pip, Docker Hub, AWS APIs, CloudWatch agent.
  # ------------------------------------------------------------------
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ec2-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}