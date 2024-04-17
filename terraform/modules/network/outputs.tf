output "subnet_private_a" {
  value = aws_subnet.private_a
}

output "subnet_private_b" {
  value = aws_subnet.private_b
}

output "subnet_public_a" {
  value = aws_subnet.public_a
}

output "subnet_public_b" {
  value = aws_subnet.public_b
}

output "subnet_database_a" {
  value = aws_subnet.database_a
}

output "subnet_database_b" {
  value = aws_subnet.database_b
}

output "dashboard_sg" {
  value = aws_security_group.dashboard
}

output "loadbalancer_sg" {
  value = aws_security_group.loadbalancer
}

output "database_sg" {
  value = aws_security_group.database
}

output "renderer_sg" {
  value = aws_security_group.renderer
}

output "pirana_sg" {
  value = aws_security_group.pirana
}
output "scheduler_sg" {
  value = aws_security_group.scheduler
}

output "adminer_sg" {
  value = aws_security_group.adminer
}

output "efs_sg" {
  value = aws_security_group.efs
}

output "vpc" {
  value = aws_vpc.pi
}

output "dashboard_prep_sg" {
  value = aws_security_group.dashboard_prep
}
