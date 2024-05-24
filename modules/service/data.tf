# This is to enable using ALBRequestCountPerTarget metric in scaling policies - resource label is created based on this
# uses only first load balancer as a data source
data "aws_lb_target_group" "tg_from_arn" {
  count = length(try(var.load_balancer[0].target_group_arn, "")) > 0 ? 1 : 0
  arn = var.load_balancer[0].target_group_arn
}
