resource "aws_ecs_cluster" "pi" {
  name = var.deployment_name
  capacity_providers = [
    "FARGATE"]
  setting {
    name = "containerInsights"
    value = var.container_insights
  }

  tags = {
    Name = var.deployment_name
  }
}


resource "aws_ecs_task_definition" "adminer" {
  family                = "${var.deployment_name}-adminer"
  container_definitions = <<EOF
  [
  {
  "logConfiguration": {
    "logDriver": "awslogs",
    "options": {
      "awslogs-group": "${var.ecs_adminer_log_group.name}",
      "awslogs-region": "${var.region}",
      "awslogs-stream-prefix": "ecs"
    }
  },
  "portMappings": [{
    "hostPort": 8080,
    "protocol": "tcp",
    "containerPort": 8080
    }
  ],
  "cpu": ${var.adminer_cpu},
  "memory": ${var.adminer_memory},
  "image": "adminer:latest",
  "essential": true,
  "name": "adminer"
  }
  ]
  EOF

  execution_role_arn = var.execution_role.arn
  task_role_arn      = var.execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = [
    "FARGATE"]
  memory = "${var.adminer_memory}"
  cpu = "${var.adminer_cpu}"
}

resource "aws_ecs_task_definition" "renderer" {
  family                = "${var.deployment_name}-renderer"
  container_definitions = <<EOF
  [
  {
  "logConfiguration": {
    "logDriver": "awslogs",
    "options": {
      "awslogs-group": "${var.ecs_renderer_log_group.name}",
      "awslogs-region": "${var.region}",
      "awslogs-stream-prefix": "ecs"
    }
  },
  "portMappings": [{
    "hostPort": 9915,
    "protocol": "tcp",
    "containerPort": 9915
    }
  ],
  "cpu": ${var.renderer_cpu},
  "repositoryCredentials": {
      "credentialsParameter": "${var.docker_hub_secrets_arn}"
    },
  "memory": ${var.renderer_memory},
  "image": "${var.renderer_image}:${var.renderer_image_version}",
  "essential": true,
  "name": "renderer"
  }
  ]
  EOF

  execution_role_arn = var.execution_role.arn
  task_role_arn      = var.execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = [
    "FARGATE"]
  memory = "${var.renderer_memory}"
  cpu = "${var.renderer_cpu}"
}


resource "aws_ecs_task_definition" "dashboard" {
  family = "${var.deployment_name}-dashboard"
  container_definitions = <<EOF
  [
  {
    "logConfiguration": {
      "logDriver": "awslogs",
      "secretOptions": null,
      "options": {
        "awslogs-group": "${var.ecs_dashboard_log_group.name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "portMappings": [
      {
        "hostPort": 8224,
        "protocol": "tcp",
        "containerPort": 8224
      }
    ],
    "cpu": ${var.dashboard_cpu},
    "environment": [
      {
        "name": "PI_DB_HOST",
        "value": "${var.dashboard_db.endpoint}"
      },
      {
        "name": "PI_DB_PASSWORD",
        "value": "${var.dashboard_db_password}"
      },
      {
        "name": "PI_DB_PORT",
        "value": "${var.dashboard_db.port}"
      },
      {
        "name": "PI_DB_SCHEMA_NAME",
        "value": "${var.dashboard_db_schema_name}"
      },
      {
        "name": "PI_DB_USERNAME",
        "value": "${var.dashboard_db_username}"
      },
      {
        "name": "PI_EXTERNAL_DB",
        "value": "true"
      },
      {
        "name": "PI_TOMCAT_MAX_MEMORY",
        "value": "${var.pi_tomcat_max_memory}"
      },
      {
        "name": "PI_LICENCE",
        "value": "${var.licence_key}"
      },
      {
        "name": "PI_TOMCAT_COOKIE_SECURE",
        "value": "true"
      },
      {
        "name": "PI_TOMCAT_COOKIE_SAMESITE",
        "value": "none"
      },
      {
        "name": "PI_PROXY_IS_SECURE",
        "value": "true"
      },
      {
        "name": "PI_PROXY_HOST",
        "value": "${var.pi_proxy_host}"
      },
      {
        "name": "PI_PROXY_PORT",
        "value": "443"
      },
      {
        "name": "PI_PROXY_SCHEME",
        "value": "https"
      },
      {
        "name": "PI_PROXY_ENABLED",
        "value": "true"
      },
      {
        "name": "RENDERER_DASHBOARD_URL",
        "value": "${var.renderer_dashboard_url}"
      }
    ],
    "repositoryCredentials": {
      "credentialsParameter": "${var.docker_hub_secrets_arn}"
    },
    "mountPoints": [
      {
        "readOnly": null,
        "containerPath": "/var/panintelligence/Dashboard/tomcat/webapps/panMISDashboardResources/themes",
        "sourceVolume": "themes"
      },
      {
        "readOnly": null,
        "containerPath": "/var/panintelligence/Dashboard/tomcat/webapps/panMISDashboardResources/images",
        "sourceVolume": "images"
      },
      {
        "readOnly": null,
        "containerPath": "/var/panintelligence/Dashboard/tomcat/webapps/panMISDashboardResources/files",
        "sourceVolume": "files"
      },
      {
        "readOnly": null,
        "containerPath": "/var/panintelligence/Dashboard/keys",
        "sourceVolume": "keys"
      },
      {
        "readOnly": null,
        "containerPath": "/var/panintelligence/Dashboard/tomcat/webapps/panMISDashboardResources/svg",
        "sourceVolume": "svg"
      },
      {
        "readOnly": null,
        "containerPath": "/var/panintelligence/Dashboard/custom_jdbc",
        "sourceVolume": "custom_jdbc"
      },
      {
        "readOnly": null,
        "containerPath": "/var/panintelligence/Dashboard/tomcat/webapps/panMISDashboardResources/locale",
        "sourceVolume": "locale"
      }
    ],
    "memory": ${var.dashboard_memory},
    "image": "${var.dashboard_image}:${var.dashboard_image_version}",
    "essential": true,
    "name": "dashboard"
  }
  ]
  EOF

  network_mode = "awsvpc"
  requires_compatibilities = [
    "FARGATE"]
  memory = "${var.dashboard_memory}"
  cpu = "${var.dashboard_cpu}"
  execution_role_arn = var.execution_role.arn
  task_role_arn = var.execution_role.arn

  volume {
    name = "themes"
    efs_volume_configuration {
      file_system_id = var.dashboard_efs.id
      root_directory = "/themes"
    }
  }

  volume {
    name = "locale"
    efs_volume_configuration {
      file_system_id = var.dashboard_efs.id
      root_directory = "/locale"
    }
  }

  volume {
    name = "keys"
    efs_volume_configuration {
      file_system_id = var.dashboard_efs.id
      root_directory = "/keys"
    }
  }

  volume {
    name = "images"
    efs_volume_configuration {
      file_system_id = var.dashboard_efs.id
      root_directory = "/images"
    }
  }

  volume {
    name = "files"
    efs_volume_configuration {
      file_system_id = var.dashboard_efs.id
      root_directory = "/files"
    }
  }

  volume {
    name = "svg"
    efs_volume_configuration {
      file_system_id = var.dashboard_efs.id
      root_directory = "/svg"
    }
  }

  volume {
    name = "custom_jdbc"
    efs_volume_configuration {
      file_system_id = var.dashboard_efs.id
      root_directory = "/custom_jdbc"
    }
  }
}


resource "aws_ecs_task_definition" "scheduler" {
  family = "${var.deployment_name}-scheduler"
  container_definitions = <<EOF
  [
  {
    "logConfiguration": {
      "logDriver": "awslogs",
      "secretOptions": null,
      "options": {
        "awslogs-group": "${var.ecs_scheduler_log_group.name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "portMappings": [
      {
        "hostPort": 9917,
        "protocol": "tcp",
        "containerPort": 9917
      }
    ],
    "cpu": ${var.scheduler_cpu},
    "environment": [
      {
        "name": "PI_DB_HOST",
        "value": "${var.dashboard_db.endpoint}"
      },
      {
        "name": "PI_DB_PASSWORD",
        "value": "${var.dashboard_db_password}"
      },
      {
        "name": "PI_DB_PORT",
        "value": "${var.dashboard_db.port}"
      },
      {
        "name": "PI_DB_SCHEMA_NAME",
        "value": "${var.dashboard_db_schema_name}"
      },
      {
        "name": "PI_DB_USERNAME",
        "value": "${var.dashboard_db_username}"
      }
    ],
    "mountPoints": [
      {
        "readOnly": null,
        "containerPath": "/var/panintelligence/Dashboard/keys",
        "sourceVolume": "keys"
      }
    ],
    "repositoryCredentials": {
      "credentialsParameter": "${var.docker_hub_secrets_arn}"
    },
    "memory": ${var.scheduler_memory},
    "image": "${var.scheduler_image}:${var.scheduler_image_version}",
    "essential": true,
    "name": "scheduler"
  }
  ]
  EOF

  volume {
    name = "keys"
    efs_volume_configuration {
      file_system_id = var.dashboard_efs.id
      root_directory = "/keys"
    }
  }

  network_mode = "awsvpc"
  requires_compatibilities = [
    "FARGATE"]
  memory = "${var.scheduler_memory}"
  cpu = "${var.scheduler_cpu}"
  execution_role_arn = var.execution_role.arn
  task_role_arn = var.execution_role.arn
}

resource "aws_ecs_task_definition" "pirana" {
  family = "${var.deployment_name}-pirana"
  container_definitions = <<TASK_DEFINITION
  [
  {
    "logConfiguration": {
      "logDriver": "awslogs",
      "secretOptions": null,
      "options": {
        "awslogs-group": "${var.ecs_pirana_log_group.name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "portMappings": [
      {
        "hostPort": 9918,
        "protocol": "tcp",
        "containerPort": 9918
      }
    ],
    "cpu": ${var.pirana_cpu},
    "repositoryCredentials": {
      "credentialsParameter": "${var.docker_hub_secrets_arn}"
    },
    "memory": ${var.pirana_memory},
    "image": "${var.pirana_image}:${var.pirana_image_version}",
    "essential": true,
    "name": "pirana"
  }
]
TASK_DEFINITION

  network_mode = "awsvpc"
  requires_compatibilities = [
    "FARGATE"]
  memory = "${var.pirana_memory}"
  cpu = "${var.pirana_cpu}"
  execution_role_arn = var.execution_role.arn
  task_role_arn = var.execution_role.arn
}

resource "aws_ecs_service" "pirana" {
  name = "pirana"
  cluster = aws_ecs_cluster.pi.id
  task_definition = aws_ecs_task_definition.pirana.arn
  desired_count = 1
  launch_type = "FARGATE"
  platform_version = "1.4.0"

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    subnets = [var.private_subnet_b.id, var.private_subnet_a.id]
    security_groups = [var.pirana_sg.id]
    assign_public_ip = true
  }

    load_balancer {
    target_group_arn = var.pirana_target_group.arn
    container_name = "pirana"
    container_port = 9918
  }
}

resource "aws_ecs_service" "dashboard" {
  name = "dashboard"
  cluster = aws_ecs_cluster.pi.id
  task_definition = aws_ecs_task_definition.dashboard.arn
  desired_count = 1
  launch_type = "FARGATE"
  platform_version = "1.4.0"
  health_check_grace_period_seconds = 80

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    subnets = [var.private_subnet_a.id, var.private_subnet_b.id]
    security_groups = [var.dashboard_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.dashboard_target_group.arn
    container_name = "dashboard"
    container_port = 8224
  }
}


resource "aws_ecs_service" "renderer" {
  name = "renderer"
  cluster = aws_ecs_cluster.pi.id
  task_definition = aws_ecs_task_definition.renderer.arn
  desired_count = 1
  launch_type = "FARGATE"
  platform_version = "1.4.0"

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    subnets = [var.private_subnet_b.id, var.private_subnet_a.id]
    security_groups = [var.renderer_sg.id]
    assign_public_ip = true
  }

    load_balancer {
    target_group_arn = var.renderer_target_group.arn
    container_name = "renderer"
    container_port = 9915
  }
}

resource "aws_ecs_service" "scheduler" {
  name = "scheduler"
  cluster = aws_ecs_cluster.pi.id
  task_definition = aws_ecs_task_definition.scheduler.arn
  desired_count = 1
  launch_type = "FARGATE"
  platform_version = "1.4.0"

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    subnets = [var.private_subnet_b.id, var.private_subnet_a.id]
    security_groups = [var.scheduler_sg.id]
    assign_public_ip = true
  }

    load_balancer {
    target_group_arn = var.scheduler_target_group.arn
    container_name = "scheduler"
    container_port = 9917
  }
}

resource "aws_ecs_service" "adminer" {
  name = "adminer"
  cluster = aws_ecs_cluster.pi.id
  task_definition = aws_ecs_task_definition.adminer.arn
  desired_count = 1
  launch_type = "FARGATE"
  platform_version = "1.4.0"

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    subnets = [var.private_subnet_b.id, var.private_subnet_a.id]
    security_groups = [var.adminer_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.adminer_target_group.arn
    container_name = "adminer"
    container_port = 8080
  }
}

