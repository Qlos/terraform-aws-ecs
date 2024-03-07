locals {
  ecs_security_group_id = var.create_security_group == false ? (var.associated_security_group_id != "" ? var.associated_security_group_id : "") : aws_security_group.instance[0].id
  user_data_block = <<-EOT
Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
${var.custom_userdata_directives}

output : { all : '| tee -a /var/log/cloud-init-output.log' }

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"

${data.template_file.user_data.rendered}
--//--
EOT
}

# Get latest Linux 2 ECS-optimized AMI by Amazon
data "aws_ami" "latest_ecs_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_launch_template" "launch_template" {
  name_prefix             = "${var.name}_"
  image_id               = var.aws_ami != "" ? var.aws_ami : data.aws_ami.latest_ecs_ami.image_id
  instance_type          = var.instance_type
  user_data              = base64encode(local.user_data_block)

  key_name               = var.key_name

  update_default_version = true

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs.id
  }

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings

    content {
      device_name = try(block_device_mappings.value.device_name, null)

      dynamic "ebs" {
        for_each = try([block_device_mappings.value.ebs], [])

        content {
          delete_on_termination = try(ebs.value.delete_on_termination, null)
          encrypted             = try(ebs.value.encrypted, null)
          iops                  = try(ebs.value.iops, null)
          kms_key_id            = try(ebs.value.kms_key_id, null)
          snapshot_id           = try(ebs.value.snapshot_id, null)
          throughput            = try(ebs.value.throughput, null)
          volume_size           = try(ebs.value.volume_size, null)
          volume_type           = try(ebs.value.volume_type, null)
        }
      }

      no_device    = try(block_device_mappings.value.no_device, null)
      virtual_name = try(block_device_mappings.value.virtual_name, null)
    }
  }

  dynamic "metadata_options" {
    for_each = length(var.metadata_options) > 0 ? [var.metadata_options] : []

    content {
      http_endpoint               = try(metadata_options.value.http_endpoint, null)
      http_protocol_ipv6          = try(metadata_options.value.http_protocol_ipv6, null)
      http_put_response_hop_limit = try(metadata_options.value.http_put_response_hop_limit, null)
      http_tokens                 = try(metadata_options.value.http_tokens, null)
      instance_metadata_tags      = try(metadata_options.value.instance_metadata_tags, null)
    }
  }

  dynamic "monitoring" {
    for_each = var.enable_monitoring ? [1] : []

    content {
      enabled = var.enable_monitoring
    }
  }

  network_interfaces {
    security_groups             = ["${local.ecs_security_group_id}"]
  }

  tags = merge(
    {
      "org"      = var.org
      "app"      = var.app_name
      "env"      = var.env
      "owner"    = var.owner
    },
    var.extra_tags,
  )

#  instance_market_options {
#    market_type = "spot"
#  }
}

# Instances are scaled across availability zones http://docs.aws.amazon.com/autoscaling/latest/userguide/auto-scaling-benefits.html 
resource "aws_autoscaling_group" "asg_spot" {
  count                = var.spot_instances == true ? 1 : 0
  name                 = "${var.name}_${var.instance_group}"
  max_size             = var.max_size
  min_size             = var.min_size
  desired_capacity     = var.desired_capacity
  force_delete         = true
  vpc_zone_identifier  = var.private_subnet_ids
  load_balancers       = var.load_balancers

  mixed_instances_policy {
      instances_distribution {
        on_demand_base_capacity                  = 0
        on_demand_percentage_above_base_capacity = 0
        spot_allocation_strategy                 = "lowest-price"
      }

      launch_template {
        launch_template_specification {
          launch_template_id = aws_launch_template.launch_template.id
        }
        
        override {
            instance_type = "${var.instance_type}"
            weighted_capacity = "3"
        }

        dynamic "override" {
            for_each = "${var.familiar_instance_types}"
              content {
                  instance_type = "${override.value}"
                  weighted_capacity = "2"
              }
        }
     }
  }

  tag {
        key                 = "org"
        value               = var.org
        propagate_at_launch = true
      }

  tag {
        key                 = "app"
        value               = var.app_name
        propagate_at_launch = true
  }
  tag {
        key                 = "env"
        value               = var.env
        propagate_at_launch = true
  }
  tag {
        key                 = "owner"
        value               = var.owner
        propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.extra_tags
    content {
      key                 = tag.value.key
      propagate_at_launch = tag.value.propagate_at_launch
      value               = tag.value.value
    }
  }

  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }
}

resource "aws_autoscaling_group" "asg" {
  count                = var.spot_instances == false ? 1 : 0
  name                 = "${var.name}_${var.instance_group}"
  max_size             = var.max_size
  min_size             = var.min_size
  desired_capacity     = var.desired_capacity
  force_delete         = true
  vpc_zone_identifier  = var.private_subnet_ids
  load_balancers       = var.load_balancers

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  tag {
        key                 = "org"
        value               = var.org
        propagate_at_launch = true
      }

  tag {
        key                 = "app"
        value               = var.app_name
        propagate_at_launch = true
  }
  tag {
        key                 = "env"
        value               = var.env
        propagate_at_launch = true
  }
  tag {
        key                 = "owner"
        value               = var.owner
        propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.extra_tags
    content {
      key                 = tag.value.key
      propagate_at_launch = tag.value.propagate_at_launch
      value               = tag.value.value
    }
  }

  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user_data.sh")}"

  vars = {
    ecs_config                             = var.ecs_config
    ecs_reserved_ports                    = var.ecs_reserved_ports
    ecs_reserved_udp_ports                = var.ecs_reserved_udp_ports
    ecs_logging                           = var.ecs_logging
    ecs_log_level                         = var.ecs_log_level
    ecs_log_file                           = var.ecs_log_file
    cluster_name                          = var.name
    env_name                              = var.org
    custom_userdata                       = var.custom_userdata
    cloudwatch_prefix                      = var.cloudwatch_prefix
    ecs_disable_image_cleanup             = var.ecs_disable_image_cleanup
    ecs_image_cleanup_interval            = var.ecs_image_cleanup_interval
    ecs_image_minimum_cleanup_age         = var.ecs_image_minimum_cleanup_age
    non_ecs_image_minimum_cleanup_age     = var.non_ecs_image_minimum_cleanup_age
    ecs_num_images_delete_per_cycle       = var.ecs_num_images_delete_per_cycle
    ecs_engine_task_cleanup_wait_duration = var.ecs_engine_task_cleanup_wait_duration
    ecs_container_stop_timeout            = var.ecs_container_stop_timeout
    ecs_enable_spot_instance_draining     = var.ecs_enable_spot_instance_draining
    ecs_image_pull_behavior               = var.ecs_image_pull_behavior
    ecs_datadir                           = var.ecs_datadir
    ecs_checkpoint                        = var.ecs_checkpoint
    health_check_port                     = var.tg_health_check_port 
  }
}

resource "aws_autoscaling_attachment" "asg_spot_attachment" {
  count = var.lb_target_group != null ? (var.spot_instances == true ? 1 : 0) : 0
  autoscaling_group_name = aws_autoscaling_group.asg_spot[0].id
  lb_target_group_arn    = var.lb_target_group
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  count = var.lb_target_group != null ? (var.spot_instances == false ? 1 : 0) : 0
  autoscaling_group_name = aws_autoscaling_group.asg[0].id
  lb_target_group_arn    = var.lb_target_group
}

resource "aws_ecs_cluster" "cluster" {
  name = var.name
  tags = merge(
    {
      "org"      = var.org
      "app"      = var.app_name
      "env"      = var.env
      "owner"    = var.owner
    },
    var.extra_tags,
  )
}
