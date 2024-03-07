resource "aws_iam_role" "ecs_execution_task" {
  name        = "ecsTaskExecutionRole"
  description = "Allows ECS tasks to call AWS services on your behalf."

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

  tags = merge(
    {
      "Name"     = "ecsTaskExecutionRole"
      "org"      = var.org
      "app"      = var.app_name
      "env"      = var.env
      "owner"    = var.owner
    },
    var.extra_tags,
  )
}

resource "aws_iam_policy" "ecs_execution_task" {
  name = "${var.name}_task_execution_role_task"
  path = "/ecs/"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "secretsmanager:GetSecretValue"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
  })

  tags = merge(
    {
      "Name"     = "${var.name}_task_execution_role_task"
      "org"      = var.org
      "app"      = var.app_name
      "env"      = var.env
      "owner"    = var.owner
    },
    var.extra_tags,
  )
}

resource "aws_iam_policy_attachment" "ecs_execution_task" {
  name       = "${var.name}_task_execution_role_task"
  roles      = ["${aws_iam_role.ecs_execution_task.name}"]
  policy_arn = aws_iam_policy.ecs_execution_task.arn
}

resource "aws_iam_role" "ecs_default_task" {
  name = "${var.name}_default_task"
  path = "/ecs/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

  tags = merge(
    {
      "Name"     = "${var.name}_ecs_instance_profile"
      "org"      = var.org
      "app"      = var.app_name
      "env"      = var.env
      "owner"    = var.owner
    },
    var.extra_tags,
  )
}

data "aws_caller_identity" "current_role_identity" {}

data "aws_region" "current_role_region" {}

data "template_file" "policy" {
  template = file("templates/aws_caller_identity.json")

  vars = {
    account_id = data.aws_caller_identity.current_role_identity.account_id
    prefix     = var.ecs_policy_role_prefix
    aws_region = data.aws_region.current_role_region.name
  }
}

resource "aws_iam_policy" "ecs_default_task" {
  name = "${var.name}_ecs_default_task"
  path = "/"

  policy = data.template_file.policy.rendered

  tags = merge(
    {
      "Name"     = "${var.name}_ecs_instance_profile"
      "org"      = var.org
      "app"      = var.app_name
      "env"      = var.env
      "owner"    = var.owner
    },
    var.extra_tags,
  )
}

resource "aws_iam_policy_attachment" "ecs_default_task" {
  name       = "${var.name}_ecs_default_task"
  roles      = ["${aws_iam_role.ecs_default_task.name}"]
  policy_arn = aws_iam_policy.ecs_default_task.arn
}
