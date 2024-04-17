data "aws_iam_policy_document" "vpc_lambda" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "vpc_lambda" {
  name = "${var.deployment_name}-vpc-lambda"
  path = "/"
  description = "Allow a lambda function to execute inside a vpc. Must be present when creating the lambda function."

  policy = data.aws_iam_policy_document.vpc_lambda.json

}

resource "aws_iam_role_policy_attachment" "vpc_lambda_dashboard_cleanup" {
  role = var.dashboard_prep_lambda_role.name
  policy_arn = aws_iam_policy.vpc_lambda.arn
}

resource "aws_lambda_function" "dashboard_prep" {
  filename = "${path.module}/../files/dashboard_prep.zip"
  function_name = "${var.deployment_name}_dashboard_prep"
  role = var.dashboard_prep_lambda_role.arn
  handler = "dashboard_prep.lambda_handler"

  runtime = "python3.8"
  source_code_hash = filebase64sha256("${path.module}/../files/dashboard_prep.zip")
  vpc_config {
    subnet_ids = [var.private_subnet_a.id, var.private_subnet_b.id]
    security_group_ids = [
      var.dashboard_prep_lambda_sg.id]
  }

  file_system_config {
    arn = var.efs_access_point.arn
    local_mount_path = "/mnt/efs"
  }

  memory_size = 512

  timeout = 30

  depends_on = [
    var.efs_mount_target_a,
    var.efs_mount_target_b]

  tags = {
    Billing = var.deployment_name
  }
}
