# helper objects
resource "random_string" "cp_random_suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  execute_command_configuration = {
    logging = "OVERRIDE"
    log_configuration = {
      cloud_watch_log_group_name = try(aws_cloudwatch_log_group.cluster[0].name, null)
    }
  }

  cloudwatch_cluster_name = "/aws/ecs/${var.name}"

  capacity_providers_names           = { for k, v in var.capacity_providers : k => "${k}_${random_string.cp_random_suffix.result}" }
  node_groups_autoscaling_group_arns = compact([for group in module.node_group : group.autoscaling_group_arn])
}

# Get latest Linux 2 ECS-optimized AMI by Amazon
data "aws_ami" "latest_ecs_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-ecs-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"]
}

resource "aws_ecs_cluster" "this" {

  name = var.name

  dynamic "configuration" {
    for_each = var.create_cloudwatch_log_group ? [var.cluster_configuration] : []

    content {
      dynamic "execute_command_configuration" {
        for_each = try([merge(local.execute_command_configuration, configuration.value.execute_command_configuration)], [{}])

        content {
          kms_key_id = try(execute_command_configuration.value.kms_key_id, null)
          logging    = try(execute_command_configuration.value.logging, "DEFAULT")

          dynamic "log_configuration" {
            for_each = try([execute_command_configuration.value.log_configuration], [])

            content {
              cloud_watch_encryption_enabled = try(log_configuration.value.cloud_watch_encryption_enabled, null)
              cloud_watch_log_group_name     = try(log_configuration.value.cloud_watch_log_group_name, null)
              s3_bucket_name                 = try(log_configuration.value.s3_bucket_name, null)
              s3_bucket_encryption_enabled   = try(log_configuration.value.s3_bucket_encryption_enabled, null)
              s3_key_prefix                  = try(log_configuration.value.s3_key_prefix, null)
            }
          }
        }
      }
    }
  }

  dynamic "configuration" {
    for_each = !var.create_cloudwatch_log_group && length(var.cluster_configuration) > 0 ? [var.cluster_configuration] : []

    content {
      dynamic "execute_command_configuration" {
        for_each = try([configuration.value.execute_command_configuration], [{}])

        content {
          kms_key_id = try(execute_command_configuration.value.kms_key_id, null)
          logging    = try(execute_command_configuration.value.logging, "DEFAULT")

          dynamic "log_configuration" {
            for_each = try([execute_command_configuration.value.log_configuration], [])

            content {
              cloud_watch_encryption_enabled = try(log_configuration.value.cloud_watch_encryption_enabled, null)
              cloud_watch_log_group_name     = try(log_configuration.value.cloud_watch_log_group_name, null)
              s3_bucket_name                 = try(log_configuration.value.s3_bucket_name, null)
              s3_bucket_encryption_enabled   = try(log_configuration.value.s3_bucket_encryption_enabled, null)
              s3_key_prefix                  = try(log_configuration.value.s3_key_prefix, null)
            }
          }
        }
      }
    }
  }

  dynamic "service_connect_defaults" {
    for_each = length(var.cluster_service_connect_defaults) > 0 ? [var.cluster_service_connect_defaults] : []

    content {
      namespace = service_connect_defaults.value.namespace
    }
  }

  dynamic "setting" {
    for_each = flatten([var.cluster_settings])

    content {
      name  = setting.value.name
      value = setting.value.value
    }
  }

  tags = var.tags
}

resource "aws_ecs_capacity_provider" "this" {
  for_each = var.capacity_providers
  name     = local.capacity_providers_names[each.key]
  auto_scaling_group_provider {
    auto_scaling_group_arn         = local.node_groups_autoscaling_group_arns[each.value.node_group_index]
    managed_termination_protection = try(each.value.auto_scaling_group_provider.managed_termination_protection, "DISABLED")
    managed_draining               = try(each.value.auto_scaling_group_provider.managed_draining, "ENABLED")
    managed_scaling {
      instance_warmup_period    = try(each.value.auto_scaling_group_provider.managed_scaling.instance_warmup_period, 0) # no warmup
      maximum_scaling_step_size = try(each.value.auto_scaling_group_provider.managed_scaling.maximum_scaling_step_size, 1)
      minimum_scaling_step_size = try(each.value.auto_scaling_group_provider.managed_scaling.minimum_scaling_step_size, 1)
      status                    = try(each.value.auto_scaling_group_provider.managed_scaling.status, "ENABLED")
      target_capacity           = try(each.value.auto_scaling_group_provider.managed_scaling.target_capacity, 100)
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = [ for k, v in aws_ecs_capacity_provider.this : v.name ]
}

resource "aws_cloudwatch_log_group" "cluster" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  name              = local.cloudwatch_cluster_name
  retention_in_days = var.cloudwatch_log_group_retention_in_days

  tags = merge(var.tags, var.cloudwatch_log_group_tags)
}

resource "aws_cloudwatch_log_group" "dmesg" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  name              = "${local.cloudwatch_cluster_name}/var/log/dmesg"
  retention_in_days = var.cloudwatch_log_group_retention_in_days

  tags = merge(var.tags, var.cloudwatch_log_group_tags)
}

resource "aws_cloudwatch_log_group" "ecs-agent" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  name              = "${local.cloudwatch_cluster_name}/var/log/ecs/ecs-agent.log"
  retention_in_days = var.cloudwatch_log_group_retention_in_days

  tags = merge(var.tags, var.cloudwatch_log_group_tags)
}

resource "aws_cloudwatch_log_group" "ecs-init" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  name              = "${local.cloudwatch_cluster_name}/var/log/ecs/ecs-init.log"
  retention_in_days = var.cloudwatch_log_group_retention_in_days

  tags = merge(var.tags, var.cloudwatch_log_group_tags)
}

resource "aws_cloudwatch_log_group" "audit" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  name              = "${local.cloudwatch_cluster_name}/var/log/ecs/audit.log"
  retention_in_days = var.cloudwatch_log_group_retention_in_days

  tags = merge(var.tags, var.cloudwatch_log_group_tags)
}
