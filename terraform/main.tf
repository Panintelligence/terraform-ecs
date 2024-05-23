provider "aws" {
  version = "~> 2.7"
  region = var.region
}

module "auto_scaling" {
  source = "./modules/auto-scaling"
  ecs_cluster = module.ecs.ecs_cluster
  ecs_dashboard_service = module.ecs.ecs_dashboard_service
  ecs_renderer_service = module.ecs.ecs_renderer_service
  deployment_name = var.deployment_name

  ecs_scheduler_service = module.ecs.ecs_scheduler_service
}

module "network" {
  source = "./modules/network"
  region = var.region
  deployment_name = var.deployment_name
  vpc_cidr_block = var.vpc_cidr_block
}

module "rds" {
  source = "./modules/rds"
  region = var.region
  dashboard_db_password = var.dashboard_db_password
  dashboard_db_username = var.dashboard_db_username
  deployment_name = var.deployment_name
  database_sg = module.network.database_sg
  subnet_database_a = module.network.subnet_database_a
  subnet_database_b = module.network.subnet_database_b
  engine_version  = var.engine_version
  family_database = var.family_database
  instance_class  = var.instance_class
}

module "efs" {
  source = "./modules/efs"
  private_subnet_a = module.network.subnet_private_a
  private_subnet_b = module.network.subnet_private_b
  efs_sg = module.network.efs_sg
  deployment_name = var.deployment_name
  efs_backup_vault_cron = var.efs_backup_vault_cron
}

module "secrets_manager" {
  source = "./modules/secrets-manager"
  docker_hub_credentials = var.docker_hub_credentials
  deployment_name = var.deployment_name
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
  deployment_name = var.deployment_name
}

module "elb" {
  source = "./modules/elb"
  hosted_zone_edit_role_arn = var.hosted_zone_edit_role_arn
  hosted_zone_id = var.hosted_zone_id
  region = var.region
  vpc_id = module.network.vpc.id
  deployment_name = var.deployment_name
  load_balancer_security_group = module.network.loadbalancer_sg
  public_subnet_a = module.network.subnet_public_a
  public_subnet_b = module.network.subnet_public_b
  certificate_arn = var.certificate_arn
}

module "iam" {
  source = "./modules/iam"
  docker_hub_secret = module.secrets_manager.docker_hub_credentials
  elb = module.elb.elb
}

module "ecs" {
  source = "./modules/ecs"
  dashboard_db = module.rds.dashboard_db
  dashboard_efs = module.efs.dashboard_efs
  dashboard_sg = module.network.dashboard_sg
  dashboard_target_group = module.elb.dashboard_target_group
  renderer_target_group = module.elb.renderer_target_group
  docker_hub_secrets_arn = module.secrets_manager.docker_hub_credentials.arn
  ecs_dashboard_log_group = module.cloudwatch.ecs_dashboard_log_group
  ecs_pirana_log_group = module.cloudwatch.ecs_pirana_log_group
  execution_role = module.iam.ecs_service_role
  licence_key = var.licence_key
  dashboard_db_password = var.dashboard_db_password
  dashboard_db_username = var.dashboard_db_username
  region = var.region
  ecs_renderer_log_group = module.cloudwatch.ecs_renderer_log_group
  deployment_name = var.deployment_name
  private_subnet_a = module.network.subnet_private_a
  private_subnet_b = module.network.subnet_private_b
  renderer_sg = module.network.renderer_sg
  ecs_adminer_log_group = module.cloudwatch.ecs_adminer_log_group
  adminer_sg = module.network.adminer_sg
  adminer_target_group = module.elb.adminer_target_group
  ecs_scheduler_log_group = module.cloudwatch.ecs_scheduler_log_group
  scheduler_sg            = module.network.scheduler_sg
  scheduler_target_group  = module.elb.scheduler_target_group
  container_insights = var.container_insights
  adminer_cpu    = var.adminer_cpu
  adminer_memory = var.adminer_memory
  renderer_cpu = var.renderer_cpu
  renderer_memory = var.renderer_memory
  dashboard_cpu    = var.dashboard_cpu
  dashboard_memory = var.dashboard_memory
  dashboard_db_schema_name = var.dashboard_db_schema_name
  pi_tomcat_max_memory = var.pi_tomcat_max_memory
  pi_proxy_host = var.pi_proxy_host
  renderer_dashboard_url = var.renderer_dashboard_url
  scheduler_cpu    = var.scheduler_cpu
  scheduler_memory = var.scheduler_memory
  pirana_cpu    = var.pirana_cpu
  pirana_memory = var.pirana_memory
  dashboard_image         = var.dashboard_image
  dashboard_image_version = var.dashboard_image_version
  pirana_image            = var.pirana_image
  pirana_image_version    = var.pirana_image_version
  renderer_image          = var.renderer_image
  renderer_image_version  = var.renderer_image_version
  scheduler_image         = var.scheduler_image
  scheduler_image_version = var.scheduler_image_version
  pirana_sg = module.network.pirana_sg
  pirana_target_group = module.elb.pirana_target_group

}

module "route53" {
  source = "./modules/route53"
  elb = module.elb.elb
  hosted_zone_edit_role_arn = var.hosted_zone_edit_role_arn
  hosted_zone_id = var.hosted_zone_id
  region = var.region
  deployment_name = var.deployment_name
}

module "lambda" {
  source = "./modules/lambda"
  private_subnet_a = module.network.subnet_private_a
  private_subnet_b = module.network.subnet_private_b
  efs_access_point = module.efs.lambda_access_point
  efs_mount_target_a = module.efs.efs_mount_point_a
  efs_mount_target_b = module.efs.efs_mount_point_b
  dashboard_prep_lambda_role = module.iam.dashboard_prep_role
  dashboard_prep_lambda_sg = module.network.dashboard_prep_sg
  deployment_name = var.deployment_name
}
