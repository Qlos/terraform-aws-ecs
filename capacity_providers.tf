resource "aws_launch_template" "cp_asg_lt" {
  for_each      = var.capacity_providers
  name          = "ecs-cluster-${var.name}-cp-${each.key}"
  description   = "Launch template for capacity provider ${each.key} in ECS cluster ${var.name}"
  image_id      = var.aws_ami != "" ? var.aws_ami : data.aws_ami.latest_ecs_ami.image_id
  instance_type = try(each.value.launch_template.instance_type, null)

  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs.arn
  }

  network_interfaces {
    security_groups             = ["${local.ecs_security_group_id}"] # TODO - or leave as is (should not allow inbound at all, use ssm)
    associate_public_ip_address = false                              # disabled - security best practice
  }

  metadata_options {
    http_tokens = try(each.value.launch_template.metadata_options.http_tokens, "required") # security best practice is to force IMDSv2
  }

  dynamic "credit_specification" {
    for_each = try(each.value.launch_template.credit_specification, null)
    content {
      cpu_credits = credit_specification.value.cpu_credits # no try - will fail if credit_specification block will be empty
    }
  }

  dynamic "instance_requirements" {
    for_each = try(each.value.launch_template.instance_requirements, null)
    content {
      burstable_performance = try(instance_requirements.value.burstable_performance, "excluded")
      instance_generations = try(instance_requirements.value.instance_generations, "current")
      local_storage = try(instance_requirements.value.local_storage, "included")
      vcpu_count {
        min = try(instance_requirements.value.vcpu_count.min, 2)
        max = try(instance_requirements.value.vcpu_count.max, try(instance_requirements.value.vcpu_count.min, 1))
      }
      memory_mib {
        min = try(instance_requirements.value.memory_mib.min, 1024)
        max = try(instance_requirements.value.memory_mib.max, try(instance_requirements.value.memory_mib.min, 1))
      }
      network_bandwidth_gbps {
        min = try(instance_requirements.value.network_bandwidth_gbps.min, 5)
        max = try(instance_requirements.value.network_bandwidth_gbps.max, try(instance_requirements.value.network_bandwidth_gbps.min, 1))
      }
    }
  }

  dynamic "monitoring" {
    for_each = try(each.value.launch_template.monitoring, null)

    content {
      enabled = monitoring.value.enabled
    }
  }

  update_default_version = true
  tags = var.tags
}

resource "aws_autoscaling_group" "cp_asg" {
  for_each = var.capacity_providers
  name = "ecs-cluster-${var.name}-cp-${each.key}"
  force_delete = try(each.value.auto_scaling_group.force_delete, false)
  min_size = 0
  max_size = each.value.auto_scaling_group.max_size
  protect_from_scale_in = try(each.value.auto_scaling_group_provider.managed_termination_protection != "DISABLED", true) # must be enabled if managed termination protection is enabled

  # either
  availability_zones = try(each.value.auto_scaling_group.availability_zones, null)
  # or
  vpc_zone_identifier = try(each.value.auto_scaling_group.subnet_ids, null)

  launch_template {
    id      = aws_launch_template.cp_asg_lt[each.key].id
    version = "$Latest"
  }
  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.value.key
      propagate_at_launch = true
      value               = tag.value.value
    }
  }
}

resource "aws_ecs_capacity_provider" "capacity_providers" {
  for_each = var.capacity_providers
  name = each.key
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.cp_asg[each.key].arn
    managed_termination_protection = try(each.value.auto_scaling_group_provider.managed_termination_protection, "ENABLED")
    managed_draining = try(each.value.auto_scaling_group_provider.managed_draining, "ENABLED")
    managed_scaling {
      instance_warmup_period    = try(each.value.auto_scaling_group_provider.managed_scaling.instance_warmup_period, null) # default 300
      maximum_scaling_step_size = try(each.value.auto_scaling_group_provider.managed_scaling.maximum_scaling_step_size, null)
      minimum_scaling_step_size = try(each.value.auto_scaling_group_provider.managed_scaling.minimum_scaling_step_size, null)
      status                    = try(each.value.auto_scaling_group_provider.managed_scaling.status, "ENABLED")
      target_capacity           = try(each.value.auto_scaling_group_provider.managed_scaling.target_capacity, null)
    }
  }
}
