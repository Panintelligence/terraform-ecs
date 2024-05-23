data "aws_availability_zones" "available" {}

resource "aws_vpc" "pi" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = var.deployment_name
    Billing = var.deployment_name
  }

}

resource "aws_internet_gateway" "pi" {
  vpc_id = aws_vpc.pi.id
  tags = {
    Name = "${var.deployment_name}-IGW"
    Billing = var.deployment_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.pi.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pi.id
  }
  tags = {
    Name = "${var.deployment_name}-public"
    Billing = var.deployment_name
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.pi.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.pi_b.id
  }
  tags = {
    Name = "${var.deployment_name}-private"
    Billing = var.deployment_name
  }
}


resource "aws_route_table" "database" {
  vpc_id = aws_vpc.pi.id
}

resource "aws_subnet" "public_a" {
  vpc_id = aws_vpc.pi.id
  cidr_block = cidrsubnet(aws_vpc.pi.cidr_block, 4, 0)
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.deployment_name}-public-a"
    Billing = var.deployment_name
  }
}

resource "aws_route_table_association" "public_a" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public_a.id
  depends_on = [aws_route_table.public]
}

resource "aws_subnet" "public_b" {
  vpc_id = aws_vpc.pi.id
  cidr_block = cidrsubnet(aws_vpc.pi.cidr_block, 4, 1)
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "${var.deployment_name}-public-b"
    Billing = var.deployment_name
  }
}

resource "aws_route_table_association" "public_b" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public_b.id
  depends_on = [aws_route_table.public]
}

resource "aws_subnet" "private_a" {
  vpc_id = aws_vpc.pi.id
  cidr_block = cidrsubnet(aws_vpc.pi.cidr_block, 4, 2)
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.deployment_name}-private-a"
    Billing = var.deployment_name
  }
}

resource "aws_route_table_association" "private_a" {
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private_a.id
  depends_on = [aws_route_table.private]
}

resource "aws_subnet" "private_b" {
  vpc_id = aws_vpc.pi.id
  cidr_block = cidrsubnet(aws_vpc.pi.cidr_block, 4, 3)
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "${var.deployment_name}-private-b"
    Billing = var.deployment_name
  }
}

resource "aws_route_table_association" "private_b" {
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private_b.id
  depends_on = [aws_route_table.private]
}

# Create the database subnets
resource "aws_subnet" "database_a" {
  vpc_id = aws_vpc.pi.id
  cidr_block = cidrsubnet(aws_vpc.pi.cidr_block, 4, 4)
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.deployment_name}-database-a"
    Billing = var.deployment_name
  }
}

resource "aws_route_table_association" "database_a" {
  route_table_id = aws_route_table.database.id
  subnet_id = aws_subnet.database_a.id
  depends_on = [aws_route_table.database]
}

resource "aws_subnet" "database_b" {
  vpc_id = aws_vpc.pi.id
  cidr_block = cidrsubnet(aws_vpc.pi.cidr_block, 4, 5)
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${var.deployment_name}-database-b"
    Billing = var.deployment_name
  }
}

resource "aws_route_table_association" "database_b" {
  route_table_id = aws_route_table.database.id
  subnet_id = aws_subnet.database_b.id
  depends_on = [aws_route_table.database]
}


resource "aws_security_group" "nat_gateway" {
  name = "${var.deployment_name}-nat-gateway"
  vpc_id = aws_vpc.pi.id

  ingress {
    from_port = 0
    protocol  = "tcp"
    to_port   = 65535
    security_groups = [aws_security_group.dashboard.id]
  }

  egress {
    from_port = 0
    protocol = "tcp"
    to_port = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.deployment_name}-nat-gateway"
    Billing = var.deployment_name
  }
}

resource "aws_security_group" "dashboard_prep" {
  name = "${var.deployment_name}-dashboard_prep"
  description = "traffic for ${var.deployment_name} dashboard prep"
  vpc_id = aws_vpc.pi.id


  egress {
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    cidr_blocks = [aws_vpc.pi.cidr_block]
  }
  tags = {
    Name = "${var.deployment_name}-dashboard-prep"
    Billing = var.deployment_name
  }
}

resource "aws_security_group" "loadbalancer" {
  name = "${var.deployment_name}-loadbalancer"
  description = "traffic for ${var.deployment_name} load balancer"
  vpc_id = aws_vpc.pi.id

  ingress {
    description = "from internet on TLS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "from internet on TLS"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "to dashboard app"
    from_port = 8224
    protocol = "tcp"
    to_port = 8224
    security_groups = [aws_security_group.dashboard.id]
  }

  egress {
    description = "to renderer app"
    from_port = 9915
    protocol  = "tcp"
    to_port   = 9915
    security_groups = [aws_security_group.renderer.id]
  }

  egress {
    description = "to scheduler app"
    from_port = 9917
    protocol  = "tcp"
    to_port   = 9917
    security_groups = [aws_security_group.scheduler.id]
  }

  egress {
    description = "to adminer app"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = [aws_security_group.adminer.id]
  }
  tags = {
    Name = "${var.deployment_name}-loadbalancer"
    Billing = var.deployment_name
  }
}

resource "aws_security_group" "dashboard" {
  name        = "${var.deployment_name}-dashboard"
  description = "Allow inbound traffic from the vpc"
  vpc_id      = aws_vpc.pi.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.deployment_name}-dashboard"
    Billing = var.deployment_name
  }
}

resource "aws_security_group_rule" "loadbalancer_dashboard_ingress"{
  from_port = 8224
  protocol  = "tcp"
  to_port   = 8224
  security_group_id = aws_security_group.dashboard.id
  source_security_group_id = aws_security_group.loadbalancer.id
  type = "ingress"
}

resource "aws_security_group" "renderer" {
  name = "${var.deployment_name}-renderer"
  description = "Allow inbound traffic to the renderer"
  vpc_id      = aws_vpc.pi.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.deployment_name}-renderer"
    Billing = var.deployment_name
  }
}

resource "aws_security_group_rule" "renderer_ingress"{
  from_port = 9915
  protocol  = "tcp"
  to_port   = 9915
  security_group_id = aws_security_group.renderer.id
  source_security_group_id = aws_security_group.loadbalancer.id
  type = "ingress"
}

resource "aws_security_group" "pirana" {
  name = "${var.deployment_name}-pirana"
  description = "Allow inbound traffic to the renderer"
  vpc_id      = aws_vpc.pi.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.deployment_name}-pirana"
    Billing = var.deployment_name
  }
}

resource "aws_security_group_rule" "pirana_ingress"{
  from_port = 9918
  protocol  = "tcp"
  to_port   = 9918
  security_group_id = aws_security_group.pirana.id
  source_security_group_id = aws_security_group.loadbalancer.id
  type = "ingress"
}

resource "aws_security_group" "database" {
  name = "${var.deployment_name}-database"
  description = "manage traffic to the databse"
  vpc_id = aws_vpc.pi.id
  ingress {
    from_port = 3306
    protocol  = "tcp"
    to_port   = 3306
    security_groups = [aws_security_group.dashboard.id]
  }

  ingress {
    from_port = 3306
    protocol  = "tcp"
    to_port   = 3306
    security_groups = [aws_security_group.scheduler.id]
  }
  tags = {
    Name = "${var.deployment_name}-database"
    Billing = var.deployment_name
  }
}

resource "aws_security_group" "adminer" {
  name = "${var.deployment_name}-adminer"
  description = "Allow communication from adminer to database"
  vpc_id = aws_vpc.pi.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.deployment_name}-adminer"
    Billing = var.deployment_name
  }
}

resource "aws_security_group_rule" "adminer_loadbalancer_ingress"{
  from_port = 8080
  protocol  = "tcp"
  to_port   = 8080
  security_group_id = aws_security_group.adminer.id
  source_security_group_id = aws_security_group.loadbalancer.id
  type = "ingress"
}

resource "aws_security_group_rule" "adminer_database_egress"{
  from_port = 3306
  protocol  = "tcp"
  to_port   = 3306
  security_group_id = aws_security_group.adminer.id
  source_security_group_id = aws_security_group.database.id
  type = "egress"
}

resource "aws_security_group_rule" "database_adminer_ingress"{
  from_port = 3306
  protocol  = "tcp"
  to_port   = 3306
  security_group_id = aws_security_group.database.id
  source_security_group_id = aws_security_group.adminer.id
  type = "ingress"
}

resource "aws_security_group" "efs" {
  name        = "pi-dashboard-efs"
  description = "Allow inbound traffic from the vpc"
  vpc_id      = aws_vpc.pi.id

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.pi.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.deployment_name}-dashboard-efs"
    Billing = var.deployment_name
  }
}


resource "aws_eip" "pi_a" {
  vpc = true
  tags = {
    Name = "${var.deployment_name}-az-a"
    Billing = var.deployment_name
  }
}

resource "aws_eip" "pi_b"{
  vpc = true
  tags = {
    Name = "${var.deployment_name}-az-b"
    Billing = var.deployment_name
  }
}

resource "aws_nat_gateway" "pi_a"{
  subnet_id = aws_subnet.public_a.id
  allocation_id = aws_eip.pi_a.id
  tags = {
    Name = "${var.deployment_name}-az-a"
  }
}

resource "aws_nat_gateway" "pi_b" {
  subnet_id = aws_subnet.public_b.id
  allocation_id = aws_eip.pi_b.id
  tags = {
    Name = "${var.deployment_name}-az-b"
    Billing = var.deployment_name
  }
}


resource "aws_security_group" "scheduler" {
  name = "${var.deployment_name}-scheduler"
  description = "Allow inbound traffic to the scheduler"
  vpc_id      = aws_vpc.pi.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.deployment_name}-scheduler"
    Billing = var.deployment_name
  }
}

resource "aws_security_group_rule" "scheduler_ingress"{
  from_port = 9917
  protocol  = "tcp"
  to_port   = 9917
  security_group_id = aws_security_group.scheduler.id
  source_security_group_id = aws_security_group.loadbalancer.id
  type = "ingress"
}

resource "aws_security_group_rule" "scheduler_database_egress"{
  from_port = 3306
  protocol  = "tcp"
  to_port   = 3306
  security_group_id = aws_security_group.scheduler.id
  source_security_group_id = aws_security_group.database.id
  type = "egress"
}