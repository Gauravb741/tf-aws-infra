output "cpu_alarm_arn" {
  description = "ARN of the CPU utilization CloudWatch alarm."
  value       = aws_cloudwatch_metric_alarm.cpu_high.arn
}

output "status_alarm_arn" {
  description = "ARN of the status check CloudWatch alarm."
  value       = aws_cloudwatch_metric_alarm.status_check_failed.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch log group."
  value       = aws_cloudwatch_log_group.app.name
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard."
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}