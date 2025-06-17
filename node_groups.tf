
locals {
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  default_instance_refresh = {
    strategy = "Rolling"
    preferences = {
      min_healthy_percentage = 66
    }
  }

  node_security_group_id = var.create_security_group == true ? aws_security_group.instance[0].id : var.associated_security_group_id

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

#!/bin/bash

dnf install -y jq aws-cli amazon-cloudwatch-agent

${var.ecs_config}
{
  echo "ECS_CLUSTER=${var.name}"
  echo "ECS_LOGFILE=${var.ecs_log_file}"
  echo "ECS_LOGLEVEL=${var.ecs_log_level}"
  echo "ECS_RESERVED_PORTS=${var.ecs_reserved_ports}"
  echo "ECS_RESERVED_PORTS_UDP=${var.ecs_reserved_udp_ports}"
  echo "ECS_DISABLE_IMAGE_CLEANUP=${var.ecs_disable_image_cleanup}"
  echo "ECS_IMAGE_CLEANUP_INTERVAL=${var.ecs_image_cleanup_interval}"
  echo "ECS_IMAGE_MINIMUM_CLEANUP_AGE=${var.ecs_image_minimum_cleanup_age}"
  echo "NON_ECS_IMAGE_MINIMUM_CLEANUP_AGE=${var.non_ecs_image_minimum_cleanup_age}"
  echo "ECS_NUM_IMAGES_DELETE_PER_CYCLE=${var.ecs_num_images_delete_per_cycle}"
  echo "ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=${var.ecs_engine_task_cleanup_wait_duration}"
  echo "ECS_CONTAINER_STOP_TIMEOUT=${var.ecs_container_stop_timeout}"
  echo "ECS_ENABLE_SPOT_INSTANCE_DRAINING=${var.ecs_enable_spot_instance_draining}"
  echo "ECS_IMAGE_PULL_BEHAVIOR=${var.ecs_image_pull_behavior}"
  echo "ECS_DATADIR=${var.ecs_datadir}"
  echo "ECS_CHECKPOINT=${var.ecs_checkpoint}"
  echo "ECS_ENGINE_AUTH_TYPE=${var.ecs_engine_auth_type}"
  echo "ECS_ENGINE_AUTH_DATA=${var.ecs_engine_auth_data}"
  echo "ECS_AVAILABLE_LOGGING_DRIVERS=${var.ecs_logging}"
} >> /etc/ecs/ecs.config

# Save dmesg logs to file
dmesg > /var/log/dmesg

# Inject the Cloudwatch logs to ECS agent
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/dmesg",
            "log_group_name": "/aws/ecs/${var.name}/var/log/dmesg",
            "log_stream_name": "${var.name}/{region}/{container_instance_id}"
          },
          {
            "file_path": "/var/log/ecs/ecs-agent.log",
            "log_group_name": "/aws/ecs/${var.name}/var/log/ecs/ecs-agent.log",
            "log_stream_name": "${var.name}/{region}/{container_instance_id}",
            "timestamp_format": "%Y-%m-%dT%H:%M:%SZ"
          },
          {
            "file_path": "/var/log/ecs/audit.log",
            "log_group_name": "/aws/ecs/${var.name}/var/log/ecs/audit.log",
            "log_stream_name": "${var.name}/{region}/{container_instance_id}",
            "timestamp_format": "%Y-%m-%dT%H:%M:%SZ"
          },
          {
            "file_path": "/var/log/ecs/ecs-init.log",
            "log_group_name": "/aws/ecs/${var.name}/var/log/ecs/ecs-init.log",
            "log_stream_name": "${var.name}/{region}/{container_instance_id}",
            "timestamp_format": "%Y-%m-%dT%H:%M:%SZ"
          }
        ]
      }
    }
  }
}
EOF

#Check IMDSv1 or IMDSv2 is being used on the instance
status_code=$(curl -s -o /dev/null -w "%%{http_code}" http://169.254.169.254/latest/meta-data/)

# Set the region to send CloudWatch Logs data to (the region where the container instance is located)
# Get availability zone where the container instance is located and remove the trailing character to give us the region.
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html
if [[ "$status_code" -eq 200 ]]
then
  region=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)
else
  region=$(TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` && curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)
fi

# Replace "{region}" with Available Zone of container instance
sed -i -e "s/{region}/$region/g" /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Set the ip address of the node
# Get the ipv4 of the container instance
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html
if [[ "$status_code" -eq 200 ]]
then
  container_instance_id=$(curl http://169.254.169.254/latest/meta-data/local-ipv4 | sed s'/.$//')
else
  container_instance_id=$(TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` && curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4 | sed s'/.$//')
fi

# Replace "{container_instance_id}" with ipv4 of container instance
sed -i -e "s/{container_instance_id}/$container_instance_id/g" /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

systemctl enable --now amazon-cloudwatch-agent

# dummy health check
# health check will not run if  port is not defined (default is empty).
# without a port, this container will return error  in the syntax of the `docker run` command  and that is ok.
docker run -p ${var.tg_health_check_port}:${var.tg_health_check_port} -d --restart unless-stopped docker.io/hashicorp/http-echo -listen=:${ var.tg_health_check_port != null ? var.tg_health_check_port : "8080" } -text="health check" 2> /dev/null

# Custom userdata script code
${var.custom_userdata}

echo "Done"

--//--
EOT

}

module "node_group" {
  source = "./modules/node-group"

  for_each = { for k, v in var.node_groups : k => v }

  # Autoscaling Group
  create_autoscaling_group = try(each.value.create_autoscaling_group, var.node_group_defaults.create_autoscaling_group, true)

  name            = try(each.value.name, each.key)
  use_name_prefix = try(each.value.use_name_prefix, var.node_group_defaults.use_name_prefix, true)

  availability_zones = try(each.value.availability_zones, var.node_group_defaults.availability_zones, null)
  subnet_ids         = try(each.value.subnet_ids, var.node_group_defaults.subnet_ids, var.subnet_ids)

  min_size                  = try(each.value.min_size, var.node_group_defaults.min_size, 0)
  max_size                  = try(each.value.max_size, var.node_group_defaults.max_size, 3)
  desired_size              = try(each.value.desired_size, var.node_group_defaults.desired_size, 1)
  capacity_rebalance        = try(each.value.capacity_rebalance, var.node_group_defaults.capacity_rebalance, null)
  min_elb_capacity          = try(each.value.min_elb_capacity, var.node_group_defaults.min_elb_capacity, null)
  wait_for_elb_capacity     = try(each.value.wait_for_elb_capacity, var.node_group_defaults.wait_for_elb_capacity, null)
  wait_for_capacity_timeout = try(each.value.wait_for_capacity_timeout, var.node_group_defaults.wait_for_capacity_timeout, null)
  default_cooldown          = try(each.value.default_cooldown, var.node_group_defaults.default_cooldown, null)
  default_instance_warmup   = try(each.value.default_instance_warmup, var.node_group_defaults.default_instance_warmup, null)
  protect_from_scale_in     = try(each.value.protect_from_scale_in, false)
  context                   = try(each.value.context, var.node_group_defaults.context, null)

  target_group_arns         = try(each.value.target_group_arns, var.node_group_defaults.target_group_arns, var.target_group_arns)
  placement_group           = try(each.value.placement_group, var.node_group_defaults.placement_group, null)
  health_check_type         = try(each.value.health_check_type, var.node_group_defaults.health_check_type, null)
  health_check_grace_period = try(each.value.health_check_grace_period, var.node_group_defaults.health_check_grace_period, null)

  force_delete           = try(each.value.force_delete, var.node_group_defaults.force_delete, null)
  force_delete_warm_pool = try(each.value.force_delete_warm_pool, var.node_group_defaults.force_delete_warm_pool, null)
  termination_policies   = try(each.value.termination_policies, var.node_group_defaults.termination_policies, [])
  suspended_processes    = try(each.value.suspended_processes, var.node_group_defaults.suspended_processes, [])
  max_instance_lifetime  = try(each.value.max_instance_lifetime, var.node_group_defaults.max_instance_lifetime, null)

  enabled_metrics         = try(each.value.enabled_metrics, var.node_group_defaults.enabled_metrics, [])
  metrics_granularity     = try(each.value.metrics_granularity, var.node_group_defaults.metrics_granularity, null)
  service_linked_role_arn = try(each.value.service_linked_role_arn, var.node_group_defaults.service_linked_role_arn, null)

  initial_lifecycle_hooks     = try(each.value.initial_lifecycle_hooks, var.node_group_defaults.initial_lifecycle_hooks, [])
  instance_maintenance_policy = try(each.value.instance_maintenance_policy, var.node_group_defaults.instance_maintenance_policy, {})
  instance_refresh            = try(each.value.instance_refresh, var.node_group_defaults.instance_refresh, local.default_instance_refresh)
  use_mixed_instances_policy  = try(each.value.use_mixed_instances_policy, var.node_group_defaults.use_mixed_instances_policy, false)
  mixed_instances_policy      = try(each.value.mixed_instances_policy, var.node_group_defaults.mixed_instances_policy, null)
  warm_pool                   = try(each.value.warm_pool, var.node_group_defaults.warm_pool, {})

  delete_timeout         = try(each.value.delete_timeout, var.node_group_defaults.delete_timeout, null)
  autoscaling_group_tags = try(each.value.autoscaling_group_tags, var.node_group_defaults.autoscaling_group_tags, {})

  # Launch Template
  create_launch_template                 = try(each.value.create_launch_template, var.node_group_defaults.create_launch_template, true)
  launch_template_id                     = try(each.value.launch_template_id, var.node_group_defaults.launch_template_id, "")
  launch_template_name                   = try(each.value.launch_template_name, var.node_group_defaults.launch_template_name, each.key)
  launch_template_use_name_prefix        = try(each.value.launch_template_use_name_prefix, var.node_group_defaults.launch_template_use_name_prefix, true)
  launch_template_version                = try(each.value.launch_template_version, var.node_group_defaults.launch_template_version, null)
  launch_template_default_version        = try(each.value.launch_template_default_version, var.node_group_defaults.launch_template_default_version, null)
  update_launch_template_default_version = try(each.value.update_launch_template_default_version, var.node_group_defaults.update_launch_template_default_version, true)
  launch_template_description            = try(each.value.launch_template_description, var.node_group_defaults.launch_template_description, "Custom launch template for ${try(each.value.name, each.key)} ECS node group")
  launch_template_tags                   = try(each.value.launch_template_tags, var.node_group_defaults.launch_template_tags, {})
  tag_specifications                     = try(each.value.tag_specifications, var.node_group_defaults.tag_specifications, ["instance", "volume", "network-interface"])

  ebs_optimized = try(each.value.ebs_optimized, var.node_group_defaults.ebs_optimized, null)
  ami_id        = try(each.value.ami_id, var.node_group_defaults.ami_id, coalesce(var.ami_id, data.aws_ami.latest_ecs_ami.image_id))
  instance_type = try(each.value.instance_type, var.node_group_defaults.instance_type, var.instance_type, null)
  key_name      = try(each.value.key_name, var.node_group_defaults.key_name, var.key_name)

  user_data = try(each.value.user_data, var.node_group_defaults.user_data, local.user_data_block)

  disable_api_termination              = try(each.value.disable_api_termination, var.node_group_defaults.disable_api_termination, null)
  instance_initiated_shutdown_behavior = try(each.value.instance_initiated_shutdown_behavior, var.node_group_defaults.instance_initiated_shutdown_behavior, null)
  kernel_id                            = try(each.value.kernel_id, var.node_group_defaults.kernel_id, null)
  ram_disk_id                          = try(each.value.ram_disk_id, var.node_group_defaults.ram_disk_id, null)

  block_device_mappings              = try(each.value.block_device_mappings, var.node_group_defaults.block_device_mappings, {})
  capacity_reservation_specification = try(each.value.capacity_reservation_specification, var.node_group_defaults.capacity_reservation_specification, {})
  cpu_options                        = try(each.value.cpu_options, var.node_group_defaults.cpu_options, {})
  credit_specification               = try(each.value.credit_specification, var.node_group_defaults.credit_specification, {})
  elastic_gpu_specifications         = try(each.value.elastic_gpu_specifications, var.node_group_defaults.elastic_gpu_specifications, {})
  elastic_inference_accelerator      = try(each.value.elastic_inference_accelerator, var.node_group_defaults.elastic_inference_accelerator, {})
  enclave_options                    = try(each.value.enclave_options, var.node_group_defaults.enclave_options, {})
  hibernation_options                = try(each.value.hibernation_options, var.node_group_defaults.hibernation_options, {})
  instance_requirements              = try(each.value.instance_requirements, var.node_group_defaults.instance_requirements, {})
  instance_market_options            = try(each.value.instance_market_options, var.node_group_defaults.instance_market_options, {})
  license_specifications             = try(each.value.license_specifications, var.node_group_defaults.license_specifications, {})
  metadata_options                   = try(each.value.metadata_options, var.node_group_defaults.metadata_options, local.metadata_options)
  enable_monitoring                  = try(each.value.enable_monitoring, var.node_group_defaults.enable_monitoring, true)
  enable_efa_support                 = try(each.value.enable_efa_support, var.node_group_defaults.enable_efa_support, false)
  network_interfaces                 = try(each.value.network_interfaces, var.node_group_defaults.network_interfaces, [])
  placement                          = try(each.value.placement, var.node_group_defaults.placement, {})
  maintenance_options                = try(each.value.maintenance_options, var.node_group_defaults.maintenance_options, {})
  private_dns_name_options           = try(each.value.private_dns_name_options, var.node_group_defaults.private_dns_name_options, {})

  iam_instance_profile_arn = try(each.value.iam_instance_profile_arn, aws_iam_instance_profile.ecs.arn)

  # Autoscaling group schedule
  create_schedule = try(each.value.create_schedule, var.node_group_defaults.create_schedule, true)
  schedules       = try(each.value.schedules, var.node_group_defaults.schedules, {})

  # Security group
  vpc_security_group_ids = compact(concat([local.node_security_group_id], try(each.value.vpc_security_group_ids, var.node_group_defaults.vpc_security_group_ids, [])))

  tags = merge(var.tags, try(each.value.tags, var.node_group_defaults.tags, {}))
}
