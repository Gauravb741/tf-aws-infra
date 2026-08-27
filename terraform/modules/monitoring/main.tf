# =============================================================================
# MONITORING MODULE
#
# Creates CloudWatch monitoring for the EC2 instance:
#   - CPU utilization alarm (triggers when CPU > threshold for 2 periods)
#   - Instance status check alarm
#   - CloudWatch Log Group for application logs
#
# Why CloudWatch?
#   CloudWatch is the native AWS monitoring service. No additional tools
#   are required, and it integrates directly with EC2, alarms, and SNS.
# =============================================================================

# -----------------------------------------------------------------------------
# CloudWatch Log Group
# Application logs from the container can be shipped here using the
# CloudWatch agent or Docker logging driver in a more advanced setup.
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/ec2/${var.project_name}/${var.environment}/application"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-app-logs"
  })
}

# -----------------------------------------------------------------------------
# CloudWatch Alarm: High CPU Utilization
#
# Triggers when average CPU > cpu_alarm_threshold % for 2 consecutive
# 5-minute periods (10 minutes total).
#
# In a production system this alarm would notify an SNS topic which
# could send emails, trigger a Lambda, or page an on-call engineer.
# For this demo the alarm is configured without an SNS action to avoid
# requiring an email address as input.
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-cpu-high"
  alarm_description   = "EC2 CPU utilization is above ${var.cpu_alarm_threshold}% for 10 minutes in ${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300 # 5 minutes
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = var.instance_id
  }

  # Uncomment and set alarm_actions to notify via SNS:
  # alarm_actions = [var.sns_topic_arn]
  # ok_actions    = [var.sns_topic_arn]

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-cpu-alarm"
  })
}

# -----------------------------------------------------------------------------
# CloudWatch Alarm: EC2 Status Check Failed
#
# EC2 performs two status checks:
#   1. System status check — AWS hardware/infrastructure
#   2. Instance status check — OS-level reachability
#
# This alarm triggers if either check fails, indicating the instance
# may need to be stopped and restarted.
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  alarm_name          = "${var.project_name}-${var.environment}-status-check-failed"
  alarm_description   = "EC2 instance status check has failed in ${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-status-alarm"
  })
}

# -----------------------------------------------------------------------------
# CloudWatch Dashboard
# Provides a visual overview of the instance metrics in the AWS console.
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "CPU Utilization"
          region = var.aws_region
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", var.instance_id]
          ]
          period = 300
          stat   = "Average"
          view   = "timeSeries"
          annotations = {
            horizontal = [
              {
                label = "Alarm threshold"
                value = var.cpu_alarm_threshold
                color = "#ff0000"
              }
            ]
          }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Status Check"
          region = var.aws_region
          metrics = [
            ["AWS/EC2", "StatusCheckFailed", "InstanceId", var.instance_id],
            ["AWS/EC2", "StatusCheckFailed_Instance", "InstanceId", var.instance_id],
            ["AWS/EC2", "StatusCheckFailed_System", "InstanceId", var.instance_id]
          ]
          period = 60
          stat   = "Maximum"
          view   = "timeSeries"
        }
      }
    ]
  })
}