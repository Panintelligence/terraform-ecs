output "ecs_dashboard_log_group" {
  value = aws_cloudwatch_log_group.ecs_dashboard_logs
}

output "ecs_renderer_log_group" {
  value = aws_cloudwatch_log_group.ecs_renderer_logs
}

output "ecs_adminer_log_group" {
  value = aws_cloudwatch_log_group.ecs_adminer_logs
}

output "ecs_scheduler_log_group" {
  value = aws_cloudwatch_log_group.ecs_scheduler_logs
}

output "ecs_pirana_log_group" {
  value = aws_cloudwatch_log_group.ecs_pirana_logs
}