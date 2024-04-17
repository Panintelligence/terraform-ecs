output "ecs_cluster" {
  value = aws_ecs_cluster.pi
}

output "ecs_dashboard_service" {
  value = aws_ecs_service.dashboard
}

output "ecs_renderer_service" {
  value = aws_ecs_service.renderer
}

output "ecs_scheduler_service" {
  value = aws_ecs_service.scheduler
}