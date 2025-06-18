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

  tags = var.tags
}

resource "aws_iam_policy" "ecs_execution_task" {
  name = "${var.name}_task_execution_role_task"
  path = "/ecs/"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Decrypt",
          "secretsmanager:GetSecretValue"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })

  tags = var.tags
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

  tags = var.tags
}

data "aws_caller_identity" "current_role_identity" {}
data "aws_region" "current_role_region" {}

data "aws_iam_policy_document" "policy" {
  statement {
    sid = ""
    effect = "Allow"
    actions = ["ssm:DescribeParameters"]
    resources = [ "*" ]
  }

  statement {
    sid = ""
    effect = "Allow"
    actions = ["ssm:GetParameters"]
    resources = [
       "arn:aws:ssm:${data.aws_region.current_role_region.name}:${data.aws_caller_identity.current_role_identity.account_id}:parameter/${var.ecs_policy_role_prefix}*"
    ]
  }
}

resource "aws_iam_policy" "ecs_default_task" {
  name = "${var.name}_ecs_default_task"
  path = "/"

  policy = data.aws_iam_policy_document.policy.json
  tags = var.tags
}

resource "aws_iam_policy_attachment" "ecs_default_task" {
  name       = "${var.name}_ecs_default_task"
  roles      = [aws_iam_role.ecs_default_task.name]
  policy_arn = aws_iam_policy.ecs_default_task.arn
}
