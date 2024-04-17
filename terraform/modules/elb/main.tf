provider "aws" {
  alias = "networks"
  version = "~> 2.7"
  region = var.region
  assume_role {
    role_arn = var.hosted_zone_edit_role_arn
  }
}

data "aws_route53_zone" "selected" {
  provider = aws.networks
  zone_id = var.hosted_zone_id
}

resource "aws_lb" "load_balancer"{
  name = "${var.deployment_name}-lb"
  internal = false
  security_groups = [var.load_balancer_security_group.id]
  subnets = [var.public_subnet_a.id, var.public_subnet_b.id]
  tags = {
    Billing = var.deployment_name
  }
}



resource "aws_lb_target_group" "dashboard" {
  name = "${var.deployment_name}-dashboard"
  port = 8224
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "ip"

  health_check {
    enabled = true
    interval = 60
    path = "/pi/version"
    timeout = 50
    matcher = "200"
    healthy_threshold = 5
    unhealthy_threshold = 5
  }

  stickiness {
    type = "lb_cookie"
  }
  tags = {
    Billing = var.deployment_name
  }
}
resource "aws_lb_target_group" "adminer" {
  name = "${var.deployment_name}-adminer"
  port = 8080
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "ip"

  health_check {
    enabled = true
    interval = 60
    path = "/"
    timeout = 50
    matcher = "200"
    healthy_threshold = 5
    unhealthy_threshold = 5
  }

  stickiness {
    type = "lb_cookie"
  }
  tags = {
    Billing = var.deployment_name
  }
}


resource "aws_lb_target_group" "renderer" {
  name = "${var.deployment_name}-renderer"
  port = 8224
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "ip"

  health_check {
    enabled = true
    interval = 60
    path = "/version"
    timeout = 50
    matcher = "200"
    healthy_threshold = 5
    unhealthy_threshold = 5
  }

  stickiness {
    type = "lb_cookie"
  }
  tags = {
    Billing = var.deployment_name
  }
}

resource "aws_lb_target_group" "scheduler" {
  name = "${var.deployment_name}-scheduler"
  port = 8224
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "ip"

  health_check {
    enabled = true
    interval = 60
    path = "/version"
    timeout = 50
    matcher = "200"
    healthy_threshold = 5
    unhealthy_threshold = 5
  }

  stickiness {
    type = "lb_cookie"
  }
  tags = {
    Billing = var.deployment_name
  }
}

resource "aws_lb_target_group" "pirana" {
  name = "${var.deployment_name}-pirana"
  port = 8224
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "ip"

  health_check {
    enabled = true
    interval = 60
    path = "/version"
    timeout = 50
    matcher = "200"
    healthy_threshold = 5
    unhealthy_threshold = 5
  }

  stickiness {
    type = "lb_cookie"
  }
  tags = {
    Billing = var.deployment_name
  }
}

resource "aws_lb_listener" "dashboard_http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      status_code = "HTTP_301"
      protocol = "HTTPS"
      port = "443"
    }
  }

}

resource "aws_lb_listener" "dashboard_https" {
  certificate_arn = var.certificate_arn
  load_balancer_arn = aws_lb.load_balancer.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "unable to find your pisaas instance, please contact your administrator support@panintelligence.com"
      status_code = "200"
    }
  }

}

resource "aws_lb_listener_rule" "dashboard" {
  listener_arn = aws_lb_listener.dashboard_https.arn

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.dashboard.arn
  }

  condition {
    host_header {
      values = ["${var.deployment_name}.${replace(data.aws_route53_zone.selected.name, "/[.]$/", "")}"]
    }
  }

}


resource "aws_lb_listener_rule" "renderer" {
  listener_arn = aws_lb_listener.dashboard_https.arn

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.renderer.arn
  }

  condition {
    host_header {
      values = ["${var.deployment_name}-renderer.${replace(data.aws_route53_zone.selected.name, "/[.]$/", "")}"]
    }
  }

}

resource "aws_lb_listener_rule" "pirana" {
  listener_arn = aws_lb_listener.dashboard_https.arn

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.pirana.arn
  }

  condition {
    host_header {
      values = ["${var.deployment_name}-pirana.${replace(data.aws_route53_zone.selected.name, "/[.]$/", "")}"]
    }
  }

}

resource "aws_lb_listener_rule" "adminer" {
  listener_arn = aws_lb_listener.dashboard_https.arn

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.adminer.arn
  }

  condition {
    host_header {
      values = ["${var.deployment_name}-adminer.${replace(data.aws_route53_zone.selected.name, "/[.]$/", "")}"]
    }
  }

}

resource "aws_lb_listener_rule" "scheduler" {
  listener_arn = aws_lb_listener.dashboard_https.arn

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.scheduler.arn
  }

  condition {
    host_header {
      values = ["${var.deployment_name}-scheduler.${replace(data.aws_route53_zone.selected.name, "/[.]$/", "")}"]
    }
  }

}

