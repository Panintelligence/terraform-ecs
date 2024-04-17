resource "aws_appautoscaling_target" "dashboard" {
  max_capacity = 1
  min_capacity = 1
  resource_id = "service/${var.ecs_cluster.name}/${var.ecs_dashboard_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"

}

resource "aws_appautoscaling_target" "renderer" {
  max_capacity = 1
  min_capacity = 1
  resource_id = "service/${var.ecs_cluster.name}/${var.ecs_renderer_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"

}

resource "aws_appautoscaling_target" "scheduler" {
  max_capacity = 1
  min_capacity = 1
  resource_id = "service/${var.ecs_cluster.name}/${var.ecs_scheduler_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"

}


resource "aws_appautoscaling_policy" "dashboard_cpu" {
  name = "${var.deployment_name}-dashboard-cpu"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.dashboard.resource_id
  scalable_dimension = aws_appautoscaling_target.dashboard.scalable_dimension
  service_namespace = aws_appautoscaling_target.dashboard.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 80
  }

}

resource "aws_appautoscaling_policy" "renderer_cpu" {
  name = "${var.deployment_name}-renderer-cpu"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.renderer.resource_id
  scalable_dimension = aws_appautoscaling_target.renderer.scalable_dimension
  service_namespace = aws_appautoscaling_target.renderer.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 80
  }

}


resource "aws_appautoscaling_policy" "scheduler_cpu" {
  name = "${var.deployment_name}-scheduler-cpu"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.scheduler.resource_id
  scalable_dimension = aws_appautoscaling_target.scheduler.scalable_dimension
  service_namespace = aws_appautoscaling_target.scheduler.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 80
  }

}



