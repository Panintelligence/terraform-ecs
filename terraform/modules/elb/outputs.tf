output "dashboard_target_group" {
  value = aws_lb_target_group.dashboard
}

output "renderer_target_group" {
  value = aws_lb_target_group.renderer
}

output "scheduler_target_group" {
  value = aws_lb_target_group.scheduler
}

output "adminer_target_group" {
  value = aws_lb_target_group.adminer
}

output "elb" {
  value = aws_lb.load_balancer
}

output "pirana_target_group" {
  value = aws_lb_target_group.pirana
}