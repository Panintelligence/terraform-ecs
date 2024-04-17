output "dashboard_efs" {
  value = aws_efs_file_system.dashboard
}

output "efs_mount_point_a" {
  value = aws_efs_mount_target.dashboard_a
}

output "efs_mount_point_b" {
  value = aws_efs_mount_target.dashboard_b
}

output "lambda_access_point" {
  value = aws_efs_access_point.access_point_for_lambda
}

