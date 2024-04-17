variable "docker_hub_credentials" {
  type = map(string)
}

variable "deployment_name" {
  default = "poc"
}

variable "region" {
}

variable "hosted_zone_edit_role_arn" {}

variable "hosted_zone_id" {}

variable "dashboard_docker_tag" {}

variable "renderer_docker_tag" {}

variable "dashboard_db_password" {}

variable "dashboard_db_username" {}

variable "licence_key" {}

variable "certificate_arn" {}

variable "vpc_cidr_block" {
  default = "11.0.0.0/16"
}

variable "instance_class" {
  default = "db.t3.medium"
}

variable "engine_version" {
  default = "10.11.6"
}

variable "family_database" {
  default = "mariadb10.11"
}

variable "efs_backup_vault_cron" {
  default = "cron(0 18 * * ? *)"
}

variable "container_insights" {
  default = "disabled"
}

variable "adminer_cpu" {
  default = 512
}

variable "adminer_memory" {
  default = 1024
}

variable "renderer_cpu" {
  default = 1024
}

variable "renderer_memory" {
  default = 2048
}

variable "dashboard_cpu" {
  default = 1024
}

variable "dashboard_memory" {
  default = 2048
}

variable "dashboard_db_schema_name" {
  default = "dashboard"
}

variable "pi_tomcat_max_memory" {
  default = 1024
}

variable "pi_proxy_host" {
}

variable "renderer_dashboard_url" {
}

variable "scheduler_cpu" {
  default = 1024
}

variable "scheduler_memory" {
  default = 2048
}

variable "pirana_cpu" {
  default = 1024
}

variable "pirana_memory" {
  default = 2048
}

variable "pirana_image" {
  default = "ghcr.io/pi-cr/pirana"
}

variable "pirana_image_version" {
  default = "2024_03"
}

variable "dashboard_image" {
  default = "ghcr.io/pi-cr/server"
}

variable "dashboard_image_version" {
  default = "2024_03"
}

variable "scheduler_image" {
  default = "ghcr.io/pi-cr/scheduler"
}

variable "scheduler_image_version" {
  default = "2024_03"
}

variable "renderer_image" {
  default = "ghcr.io/pi-cr/renderer"
}

variable "renderer_image_version" {
  default = "2024_03"
}