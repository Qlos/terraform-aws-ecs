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
    for_each = length(var.capacity_provider_strategy) > 0 ? [var.capacity_provider_strategy] : []
    content {
      base              = try(capacity_provider_strategy.value.base, null)
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = try(capacity_provider_strategy.value.weight, null)
    }
  }

  dynamic "load_balancer" {
    for_each = length(var.load_balancer) > 0 ? [var.load_balancer] : []
    content { # all is required
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

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#service_connect_configuration
  dynamic "service_connect_configuration" {
    for_each = length(try(var.service_discovery, {})) > 0 ? [var.service_discovery] : []
    content {
      enabled = true
      namespace = service_connect_configuration.value.namespace
      dynamic "service" {
        for_each = try(service_connect_configuration.value.services, [])
        content {
          discovery_name = try(service.value.discovery_name, null)
          port_name = service.value.port_name
          # currently no support for other params like client_alias, timeout, tls, ingress_port_override
        }
      }
    }
  }
}
