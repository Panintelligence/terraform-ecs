resource "aws_cloudwatch_log_group" "ecs_dashboard_logs" {
  name = "/ecs/${var.deployment_name}-dashboard"
  tags = {
    Billing = var.deployment_name
  }
}

resource "aws_cloudwatch_log_group" "ecs_renderer_logs" {
  name = "/ecs/${var.deployment_name}-renderer"
  tags = {
    Billing = var.deployment_name
  }
}

resource "aws_cloudwatch_log_group" "ecs_adminer_logs" {
  name = "/ecs/${var.deployment_name}-adminer"
  tags = {
    Billing = var.deployment_name
  }
}

resource "aws_cloudwatch_log_group" "ecs_scheduler_logs" {
  name = "/ecs/${var.deployment_name}-scheduler"
  tags = {
    Billing = var.deployment_name
  }
}

resource "aws_cloudwatch_log_group" "ecs_pirana_logs" {
  name = "/ecs/${var.deployment_name}-pirana"
  tags = {
    Billing = var.deployment_name
  }
}