output "ecs_service_role" {
  value = aws_iam_role.ecs_service
}

output "dashboard_prep_role" {
  value = aws_iam_role.dashboard_prep
}
