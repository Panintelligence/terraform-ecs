provider "aws" {
  alias   = "networks"
  version = "~> 2.7"
  region  = var.region
  assume_role {
    role_arn = var.hosted_zone_edit_role_arn
  }
}

data "aws_route53_zone" "selected" {
  provider = aws.networks
  zone_id  = var.hosted_zone_id
}

resource "aws_route53_record" "dashboard" {
  provider = aws.networks
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.deployment_name}.${data.aws_route53_zone.selected.name}"
  type    = "A"

  alias {
    name                   = var.elb.dns_name
    zone_id                = var.elb.zone_id
    evaluate_target_health = true
  }
}


resource "aws_route53_record" "renderer" {
  provider = aws.networks
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.deployment_name}-renderer.${data.aws_route53_zone.selected.name}"
  type    = "A"

  alias {
    name                   = var.elb.dns_name
    zone_id                = var.elb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "adminer" {
  provider = aws.networks
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.deployment_name}-adminer.${data.aws_route53_zone.selected.name}"
  type    = "A"

  alias {
    name                   = var.elb.dns_name
    zone_id                = var.elb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "pirana" {
  provider = aws.networks
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.deployment_name}-pirana.${data.aws_route53_zone.selected.name}"
  type    = "A"

  alias {
    name                   = var.elb.dns_name
    zone_id                = var.elb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "scheduler" {
  provider = aws.networks
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.deployment_name}-scheduler.${data.aws_route53_zone.selected.name}"
  type    = "A"

  alias {
    name                   = var.elb.dns_name
    zone_id                = var.elb.zone_id
    evaluate_target_health = true
  }
}