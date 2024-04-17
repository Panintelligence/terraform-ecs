resource "aws_secretsmanager_secret" "docker_credentials" {
  name = "${var.deployment_name}docker_hub_credentials"
}

resource "aws_secretsmanager_secret_version" "docker_credentials" {
  secret_id     = aws_secretsmanager_secret.docker_credentials.id
  secret_string = jsonencode(var.docker_hub_credentials)
}
