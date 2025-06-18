resource "aws_sns_topic" "ecs_events" {
  name = "ecs_events_${var.name}"
}

data "aws_caller_identity" "current_event_identity" {}

data "aws_region" "current_event_region" {}

resource "aws_cloudwatch_event_rule" "ecs_task_stopped" {
  name          = "${var.name}_task_stopped"
  description   = "${var.name} Essential container in task exited"
  tags          = var.tags
  event_pattern = jsonencode({
    source = ["aws.ecs"]
    detail-type = ["ECS Task State Change"]
    detail = {
      clusterArn = ["arn:aws:ecs:${data.aws_region.current_event_region.name}:${data.aws_caller_identity.current_event_identity.account_id}:cluster/${var.name}"]
      lastStatus = ["STOPPED"]
      stoppedReason = ["Essential container in task exited"]
    }
  })
}

resource "aws_cloudwatch_event_target" "event_fired" {
  rule  = aws_cloudwatch_event_rule.ecs_task_stopped.name
  arn   = aws_sns_topic.ecs_events.arn
  input = "{ \"message\": \"Essential container in task exited\", \"account_id\": \"${data.aws_caller_identity.current_event_identity.account_id}\", \"cluster\": \"${var.name}\"}"
}
