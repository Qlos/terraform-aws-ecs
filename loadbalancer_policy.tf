resource "aws_iam_role" "ecs_lb_role" {
  name = "${var.name}_ecs_lb_role"
  path = "/ecs/"

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

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_lb" {
  role       = aws_iam_role.ecs_lb_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}
