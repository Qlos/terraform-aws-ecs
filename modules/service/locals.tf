locals {
  # works only for first target group/load balancer pair - helpful if resource_label was not passed as a param for
  # target tracking scaling policy metric specification
  tg_arn_suffix = try(data.aws_lb_target_group.tg_from_arn[0].arn_suffix, "")
  lb_arn_suffix = try(regex("app/.*$", tolist(data.aws_lb_target_group.tg_from_arn[0].load_balancer_arns)[0]), "") # there should be only one lb per tg anyway
}
