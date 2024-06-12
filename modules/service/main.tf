# for now only efs volumes supported
# only the most important parameters included
# template file for container definitions must be supplied externally via container_definitions_template_file variable
# + templated veriables supplied using container_definitions_template_vars variable
# this is because container definitions are application specific and cannot be embedded in module

resource "aws_ecs_task_definition" "this" {
  family                = var.task_definition_family
  container_definitions = templatefile(var.container_definitions_template_file, var.container_definitions_template_vars)

  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  cpu                      = var.cpu
  memory                   = var.memory
  skip_destroy             = var.skip_destroy
  tags                     = var.tags

  dynamic "volume" {
    for_each = var.volumes
    content {
      name      = volume.value.name
      host_path = try(volume.value.host_path, null)

      dynamic "efs_volume_configuration" {
        for_each = try(volume.value.efs_volume_configuration, {})
        content {
          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = try(efs_volume_configuration.value.root_directory, "/")
          transit_encryption      = try(efs_volume_configuration.value.transit_encryption, "DISABLED")
          transit_encryption_port = try(efs_volume_configuration.value.transit_encryption_port, null)
          dynamic "authorization_config" {
            for_each = try(efs_volume_configuration.value.authorization_config, {})
            content {
              access_point_id = try(authorization_config.value.access_point_id, null)
              iam             = try(authorization_config.value.iam, "DISABLED")
            }
          }
        }
      }
    }
  }
}

resource "aws_ecs_service" "this" {
  name                               = var.name
  cluster                            = var.cluster_id
  desired_count                      = var.desired_count
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  enable_execute_command             = var.enable_execute_command
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  launch_type                        = var.launch_type
  tags                               = var.tags
  task_definition                    = aws_ecs_task_definition.this.arn
  propagate_tags                     = var.propagate_tags
  scheduling_strategy                = var.scheduling_strategy
  wait_for_steady_state              = var.wait_for_steady_state

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy
    content {
      base              = try(capacity_provider_strategy.value.base, null)
      capacity_provider = var.capacity_providers_names[capacity_provider_strategy.value.capacity_provider_key]
      weight            = try(capacity_provider_strategy.value.weight, null)
    }
  }

  dynamic "load_balancer" {
    for_each = var.load_balancer
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  dynamic "network_configuration" {
    for_each = length(var.service_subnet_ids) > 0 ? [1] : []
    content {
      subnets         = var.service_subnet_ids
      security_groups = var.service_security_group_ids
    }
  }

  dynamic "ordered_placement_strategy" {
    for_each = var.ordered_placement_strategy
    content {
      type = ordered_placement_strategy.value.type
      field = try(ordered_placement_strategy.value.field, null)
    }
  }

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#service_connect_configuration
  dynamic "service_connect_configuration" {
    for_each = try(length(var.service_discovery), 0) > 0 ? [var.service_discovery] : []
    content {
      enabled   = true
      namespace = service_connect_configuration.value.namespace
      dynamic "service" {
        for_each = try(service_connect_configuration.value.services, [])
        content {
          discovery_name        = try(service.value.discovery_name, null)
          ingress_port_override = try(service.value.ingress_port_override, null)
          port_name             = service.value.port_name
          dynamic "client_alias" {
            for_each = try([service.value.client_alias], [])
            content {
              dns_name = try(client_alias.value.dns_name, null)
              port     = client_alias.value.port
            }
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [ desired_count ]
  }
}

resource "aws_appautoscaling_target" "this" {
  count = length(var.autoscaling_configuration) > 0 ? 1 : 0
  min_capacity = var.autoscaling_configuration.min_capacity
  max_capacity = var.autoscaling_configuration.max_capacity
  resource_id = "service/${var.cluster_name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "this" {
  for_each = try(var.autoscaling_configuration.policies, {})

  name = each.value.name
  policy_type = each.value.policy_type

  resource_id = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace = aws_appautoscaling_target.this[0].service_namespace

  dynamic "step_scaling_policy_configuration" {
    for_each = try([each.value.step_scaling_policy_configuration], [])
    content {
      adjustment_type = step_scaling_policy_configuration.adjustment_type
      cooldown = step_scaling_policy_configuration.cooldown
      metric_aggregation_type = try(step_scaling_policy_configuration.metric_aggregation_type, null)
      min_adjustment_magnitude = try(step_scaling_policy_configuration.min_adjustment_magnitude, null)

      dynamic "step_adjustment" {
        for_each = try(step_scaling_policy_configuration.step_adjustments, [])
        content {
          metric_interval_lower_bound = try(step_adjustment.metric_interval_lower_bound, null)
          metric_interval_upper_bound = try(step_adjustment.metric_interval_upper_bound, null)
          scaling_adjustment = step_adjustment.scaling_adjustment
        }
      }
    }
  }

  dynamic "target_tracking_scaling_policy_configuration" {
    for_each = try([each.value.target_tracking_scaling_policy_configuration], [])
    content {
      target_value = each.value.target_tracking_scaling_policy_configuration.target_value
      disable_scale_in = try(each.value.target_tracking_scaling_policy_configuration.disable_scale_in, false)
      scale_in_cooldown = try(each.value.target_tracking_scaling_policy_configuration.scale_in_cooldown, null)
      scale_out_cooldown = try(each.value.target_tracking_scaling_policy_configuration.scale_out_cooldown, null)

      # custom_metric_specification not supported yet
      dynamic "predefined_metric_specification" {
        for_each = try([each.value.target_tracking_scaling_policy_configuration.predefined_metric_specification], [])
        content {
          predefined_metric_type = each.value.target_tracking_scaling_policy_configuration.predefined_metric_specification.predefined_metric_type
          resource_label = try(each.value.target_tracking_scaling_policy_configuration.predefined_metric_specification.resource_label, "${local.lb_arn_suffix}/${local.tg_arn_suffix}")
        }
      }
    }
  }
}
