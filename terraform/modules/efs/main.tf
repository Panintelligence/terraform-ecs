resource "aws_efs_file_system" "dashboard" {
  creation_token = "dashboard-efs-${var.deployment_name}"

  tags = {
    Name = "${var.deployment_name}-efs"
    Billing = var.deployment_name
  }
}

resource "aws_efs_mount_target" "dashboard_a" {
  file_system_id = aws_efs_file_system.dashboard.id
  subnet_id = var.private_subnet_a.id

  security_groups = [
    var.efs_sg.id]

}

resource "aws_efs_mount_target" "dashboard_b" {
  file_system_id = aws_efs_file_system.dashboard.id
  subnet_id = var.private_subnet_b.id

  security_groups = [
    var.efs_sg.id]

}

resource "aws_efs_access_point" "access_point_for_lambda" {
  file_system_id = aws_efs_file_system.dashboard.id

  root_directory {
    path = "/"
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "777"
    }
  }

  posix_user {
    gid = 0
    uid = 0
  }
  tags = {
    Name = var.deployment_name
    Billing = var.deployment_name
  }
}


resource "aws_iam_role" "dashboard_efs_backup" {
  name = "dashboard_efs_backup_${var.deployment_name}"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY
  tags = {
    Billing = var.deployment_name
  }
}

resource "aws_iam_role_policy_attachment" "dashboard_efs_backup" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role = aws_iam_role.dashboard_efs_backup.name
}

resource "aws_backup_vault" "dashboard_efs_backup" {
  name = "dashboard_efs_backup"
  tags = {
    Billing = var.deployment_name
  }
}

resource "aws_backup_plan" "dashboard_efs_backup" {
  name = "dashboard_efs_backup"

  rule {
    rule_name = "dashboard_efs_backup"
    target_vault_name = aws_backup_vault.dashboard_efs_backup.name
    schedule = var.efs_backup_vault_cron
  }
  tags = {
    Billing = var.deployment_name
  }
}

resource "aws_backup_selection" "dashboard" {
  iam_role_arn = aws_iam_role.dashboard_efs_backup.arn
  name = "dashboard-efs-backup"
  plan_id = aws_backup_plan.dashboard_efs_backup.id

  resources = [
    aws_efs_file_system.dashboard.arn
  ]

}
