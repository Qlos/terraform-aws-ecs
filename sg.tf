locals {
  create_security_group = var.create_security_group == true ? 1 : 0
}

resource "aws_security_group" "instance" {
  count                     = local.create_security_group
  name                      = "${var.name}_${var.instance_group}"
  description               = "Used in ${var.name} cluster"
  vpc_id                    = var.vpc_id

  tags                      = var.tags
}

resource "aws_security_group_rule" "outbound_internet_access" {
  count                     = local.create_security_group
  type                      = "egress"
  from_port                 = 0
  to_port                   = 0
  protocol                  = "-1"
  cidr_blocks               = ["0.0.0.0/0"]
  security_group_id         = aws_security_group.instance[0].id

  depends_on = [
    aws_security_group.instance,
  ]
}

resource "aws_security_group_rule" "alb_to_ecs" {
  count                     = local.create_security_group
  type                      = "ingress"
  from_port                 = 32768
  to_port                   = 61000
  protocol                  = "TCP"
  source_security_group_id  = var.alb_security_group_id
  security_group_id         = aws_security_group.instance[0].id

  depends_on = [
    aws_security_group.instance,
  ]
}

resource "aws_security_group_rule" "allowed_sgs_to_ecs" {
  count                    = local.create_security_group == 1 ? length(var.allowed_security_group_ids) : 0
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = var.allowed_security_group_ids[count.index]
  security_group_id        = aws_security_group.instance[0].id

  depends_on = [
    aws_security_group.instance,
  ]
}

resource "aws_security_group_rule" "ecs_health_check_for_alb" {
  count                    = local.create_security_group == 1 ? (var.tg_health_check_port != "" ?  (var.tg_health_check_port != "traffic-port" ? 1 : 0) : 0) : 0
  type                     = "ingress"
  from_port                = var.tg_health_check_port
  to_port                  = var.tg_health_check_port
  protocol                 = "TCP"
  description              = "HEALTH CHECK"
  source_security_group_id = var.alb_security_group_id
  security_group_id        = aws_security_group.instance[0].id

  depends_on = [
    aws_security_group.instance,
  ]
}
