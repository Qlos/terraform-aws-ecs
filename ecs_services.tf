module "ecs_services" {
  source = "./modules/service"
  for_each = var.ecs_services

  name = each.value.name
  capacity_provider_strategy = try(each.value.capacity_provider_strategy, null)
  cluster_id = aws_ecs_cluster.this.id
  deployment_maximum_percent = try(each.value.deployment_maximum_percent, null)
  deployment_minimum_healthy_percent = try(each.value.deployment_minimum_healthy_percent, null)
  desired_count = try(each.value.desired_count, 1)
  enable_execute_command = try(each.value.enable_execute_command, false)
  health_check_grace_period_seconds = try(each.value.health_check_grace_period_seconds, null)
  launch_type = try(each.value.launch_type, null)
  wait_for_steady_state = try(each.value.wait_for_steady_state, false)
  load_balancer = try(each.value.load_balancer, {})
  propagate_tags = try(each.value.propagate_tags, "TASK_DEFINITION")
  scheduling_strategy = try(each.value.scheduling_strategy, "REPLICA")
  service_subnet_ids = try(each.value.service_subnet_ids, [])
  service_security_group_ids = try(each.value.service_security_group_ids, null)

  # task definition parameters
  task_definition_family = each.value.task_definition_family
  execution_role_arn = each.value.execution_role_arn
  task_role_arn = each.value.task_role_arn
  container_definitions_template_file = each.value.container_definitions_template_file
  container_definitions_template_vars = each.value.container_definitions_template_vars
  network_mode = try(each.value.network_mode, "awsvpc")
  requires_compatibilities = try(each.value.requires_compatibilities, ["EC2"])
  cpu = try(each.value.cpu, null)
  memory = try(each.value.memory, null)
  skip_destroy = try(each.value.skip_destroy, false)
  volumes = try(each.value.volumes, [])

  # common
  tags = try(each.value.tags, {})
}
