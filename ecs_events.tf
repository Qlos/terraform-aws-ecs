resource "aws_sns_topic" "ecs_events" {
  name = "ecs_events_${var.name}"
}

data "aws_caller_identity" "current_event_identity" {}

data "aws_region" "current_event_region" {}

data "template_file" "ecs_task_stopped" {
  template = <<EOF
{
  "source": ["aws.ecs"],
  "detail-type": ["ECS Task State Change"],
  "detail": {
    "clusterArn": ["arn:aws:ecs:$${aws_region}:$${account_id}:cluster/$${cluster}"],
    "lastStatus": ["STOPPED"],
    "stoppedReason": ["Essential container in task exited"]
  }
}
EOF

  vars = {
    account_id = data.aws_caller_identity.current_event_identity.account_id
    cluster    = var.name
    aws_region = data.aws_region.current_event_region.name
  }
}

resource "aws_cloudwatch_event_rule" "ecs_task_stopped" {
  name          = "${var.name}_task_stopped"
  description   = "${var.name} Essential container in task exited"
  event_pattern = data.template_file.ecs_task_stopped.rendered
  tags          = var.tags
}

resource "aws_cloudwatch_event_target" "event_fired" {
  rule  = aws_cloudwatch_event_rule.ecs_task_stopped.name
  arn   = aws_sns_topic.ecs_events.arn
  input = "{ \"message\": \"Essential container in task exited\", \"account_id\": \"${data.aws_caller_identity.current_event_identity.account_id}\", \"cluster\": \"${var.name}\"}"
}
