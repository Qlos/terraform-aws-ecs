#!/bin/bash

# Install awslogs and the jq JSON parser
yum install -y awslogs jq aws-cli

# ECS config
${ecs_config}
{
  echo "ECS_CLUSTER=${cluster_name}"
  echo "ECS_LOGFILE=${ecs_log_file}"
  echo "ECS_LOGLEVEL=${ecs_log_level}"
  echo "ECS_RESERVED_PORTS=${ecs_reserved_ports}"
  echo "ECS_RESERVED_PORTS_UDP=${ecs_reserved_udp_ports}"
  echo "ECS_DISABLE_IMAGE_CLEANUP=${ecs_disable_image_cleanup}"
  echo "ECS_IMAGE_CLEANUP_INTERVAL=${ecs_image_cleanup_interval}"
  echo "ECS_IMAGE_MINIMUM_CLEANUP_AGE=${ecs_image_minimum_cleanup_age}"
  echo "NON_ECS_IMAGE_MINIMUM_CLEANUP_AGE=${non_ecs_image_minimum_cleanup_age}"
  echo "ECS_NUM_IMAGES_DELETE_PER_CYCLE=${ecs_num_images_delete_per_cycle}"
  echo "ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=${ecs_engine_task_cleanup_wait_duration}"
  echo "ECS_CONTAINER_STOP_TIMEOUT=${ecs_container_stop_timeout}"
  echo "ECS_ENABLE_SPOT_INSTANCE_DRAINING=${ecs_enable_spot_instance_draining}"
  echo "ECS_IMAGE_PULL_BEHAVIOR=${ecs_image_pull_behavior}"
  echo "ECS_DATADIR=${ecs_datadir}"
  echo "ECS_CHECKPOINT=${ecs_checkpoint}"
  echo 'ECS_AVAILABLE_LOGGING_DRIVERS=${ecs_logging}'
} >> /etc/ecs/ecs.config

# Inject the CloudWatch Logs configuration file contents
cat > /etc/awslogs/awslogs.conf <<- EOF
[general]
state_file = /var/lib/awslogs/agent-state        
 
[/var/log/dmesg]
file = /var/log/dmesg
log_group_name = ${cloudwatch_prefix}/var/log/dmesg
log_stream_name = ${cluster_name}/{container_instance_id}

[/var/log/messages]
file = /var/log/messages
log_group_name = ${cloudwatch_prefix}/var/log/messages
log_stream_name = ${cluster_name}/{container_instance_id}
datetime_format = %b %d %H:%M:%S

[/var/log/docker]
file = /var/log/docker
log_group_name = ${cloudwatch_prefix}/var/log/docker
log_stream_name = ${cluster_name}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%S.%f

[/var/log/ecs/ecs-init.log]
file = /var/log/ecs/ecs-init.log.*
log_group_name = ${cloudwatch_prefix}/var/log/ecs/ecs-init.log
log_stream_name = ${cluster_name}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ

[/var/log/ecs/ecs-agent.log]
file = /var/log/ecs/ecs-agent.log.*
log_group_name = ${cloudwatch_prefix}/var/log/ecs/ecs-agent.log
log_stream_name = ${cluster_name}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ

[/var/log/ecs/audit.log]
file = /var/log/ecs/audit.log.*
log_group_name = ${cloudwatch_prefix}/var/log/ecs/audit.log
log_stream_name = ${cluster_name}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ

EOF

# Set the region to send CloudWatch Logs data to (the region where the container instance is located)
# Get availability zone where the container instance is located and remove the trailing character to give us the region.
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html
region=$(curl 169.254.169.254/latest/meta-data/placement/availability-zone | sed s'/.$//')
# Replace the default log region with the region where the container instance is located.
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/QuickStartEC2Instance.html#running-ec2-step-2
sed -i -e "s/region = us-east-1/region = $region/g" /etc/awslogs/awscli.conf

# Set the ip address of the node 
# Get the ipv4 of the container instance
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html
container_instance_id=$(curl 169.254.169.254/latest/meta-data/local-ipv4)
# Replace "{container_instance_id}" with ipv4 of container instance
sed -i -e "s/{container_instance_id}/$container_instance_id/g" /etc/awslogs/awslogs.conf

systemctl enable --now awslogsd

# dummy health check
# health check will not run if  port is not defined (default is empty).
# without a port, this container will return error  in the syntax of the `docker run` command  and that is ok.
docker run -p ${health_check_port}:${health_check_port} -d --restart unless-stopped docker.io/hashicorp/http-echo -listen=:${ health_check_port != null ? health_check_port : "8080" } -text="health check" 2> /dev/null

# Custom userdata script code
${custom_userdata}

echo "Done"
