# =============================================================================
# EC2 MODULE
#
# Provisions a single EC2 instance with:
#   - Dynamic AMI lookup (latest Amazon Linux 2023)
#   - IAM instance profile (least privilege)
#   - Security group attachment
#   - User data script (installs Docker, deploys the application)
#   - CloudWatch agent configuration
#
# Why Amazon Linux 2023?
#   - AWS-maintained, security patched regularly
#   - Docker available from default repos
#   - Familiar to AWS engineers
#   - No licensing cost
# =============================================================================

# -----------------------------------------------------------------------------
# AMI: Dynamically select the latest Amazon Linux 2023 AMI
# This avoids hardcoding an AMI ID that becomes stale.
# -----------------------------------------------------------------------------
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# -----------------------------------------------------------------------------
# IAM: Role that the EC2 instance assumes
# Allows the instance to call AWS APIs (CloudWatch, SSM) without storing
# access keys on the instance. Access keys on EC2 = serious security risk.
# -----------------------------------------------------------------------------
resource "aws_iam_role" "ec2" {
  name        = "${var.project_name}-${var.environment}-ec2-role"
  description = "IAM role for ${var.project_name} EC2 instance"

  # Trust policy: only EC2 can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# CloudWatch permissions — allows the instance to push metrics and logs
resource "aws_iam_role_policy" "cloudwatch" {
  name = "${var.project_name}-${var.environment}-cloudwatch-policy"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

# SSM permissions — allows Systems Manager Session Manager (SSH alternative)
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile — wrapper that attaches the IAM role to an EC2 instance
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2.name

  tags = var.tags
}

# -----------------------------------------------------------------------------
# EC2 Instance
# -----------------------------------------------------------------------------
resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name
  key_name               = var.key_pair_name != "" ? var.key_pair_name : null

  # Attach a root volume with encryption enabled
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true

    tags = merge(var.tags, {
      Name = "${var.project_name}-${var.environment}-root-volume"
    })
  }

  # User data runs once when the instance first starts.
  # It installs Docker and deploys the application container.
  user_data = base64encode(templatefile("${path.module}/user-data.sh.tpl", {
    project_name     = var.project_name
    environment      = var.environment
    app_version      = var.app_version
    application_port = var.application_port
    docker_image     = var.docker_image
  }))

  # Replace the instance (not update in-place) when user data changes.
  # This ensures the new configuration is fully applied.
  user_data_replace_on_change = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ec2"
  })

  # Ensure IAM profile exists before the instance starts
  depends_on = [aws_iam_instance_profile.ec2]
}