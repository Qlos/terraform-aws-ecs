variable "name" {
  description = "The name of the cluster"
}

variable "cluster_configuration" {
  description = "The execute command configuration for the cluster"
  type        = any
  default     = {}
}

variable "cluster_settings" {
  description = "List of configuration block(s) with cluster settings. For example, this can be used to enable CloudWatch Container Insights for a cluster"
  type        = any
  default = [
    {
      name  = "containerInsights"
      value = "enabled"
    }
  ]
}

variable "cluster_service_connect_defaults" {
  description = "Configures a default Service Connect namespace"
  type        = map(string)
  default     = {}
}

variable "create_cloudwatch_log_group" {
  description = "Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events"
  type        = number
  default     = 90
}

variable "cloudwatch_log_group_tags" {
  description = "A map of additional tags to add to the log group created"
  type        = map(string)
  default     = {}
}

variable "instance_group" {
  default     = "default"
  description = "The name of the instances that you consider as a group"
}

variable "vpc_id" {
  description = "The VPC id"
}

variable "ami_id" {
  default     = ""
  description = "The AWS ami id to use"
}

variable "instance_type" {
  default     = null
  description = "AWS main type of EC2 instance to use"
}

variable "familiar_instance_types" {
  type        = list(any)
  default     = ["t3.large", "m5.large", "c5.xlarge"]
  description = "Used only with `spot_instance` variable. List of familiar instance types to use with lowest weight from `instance_type`"
}

variable "spot_instances" {
  type        = bool
  default     = false
  description = "Enable or disable spot instances"
}

variable "max_size" {
  default     = 1
  description = "Maximum size of the nodes in the cluster"
}

variable "min_size" {
  default     = 1
  description = "Minimum size of the nodes in the cluster"
}

#For more explenation see http://docs.aws.amazon.com/autoscaling/latest/userguide/WhatIsAutoScaling.html
variable "desired_capacity" {
  default     = 1
  description = "The desired capacity of the cluster"
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned."
  type        = list(string)
  default     = []
}

variable "create_security_group" {
  type        = bool
  default     = true
  description = "Create internal AWS SG for ECS cluster. If value is set to `false` you need set up the `associated_security_group_id` variable."
}

variable "associated_security_group_id" {
  default     = ""
  description = "Variable to use only with `associated_security_group_id` variable. This security group will be assigned to the ecs cluster instead of creating a new page"
}

variable "block_device_mappings" {
  description = "Specify volumes to attach to the instance besides the volumes specified by the AMI"
  type        = any
  default     = {}
}

variable "metadata_options" {
  description = "Customize the metadata options for the instance"
  type        = map(string)
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 2
  }
}

variable "enable_monitoring" {
  description = "Enables/disables detailed monitoring"
  type        = bool
  default     = true
}

variable "alb_security_group_id" {
  default     = ""
  description = "ALB security group id. Can be used only with `create_security_group` variable with `false` value."
}

variable "allowed_security_group_ids" {
  default     = []
  type        = list(any)
  description = "Allowed this AWS security groups to ECS cluster. Can be used only with `create_security_group` variable with `false` value."
}

variable "target_group_arns" {
  description = "A set of `aws_alb_target_group` ARNs, for use with Application or Network Load Balancing"
  type        = list(any)
  default     = []
}

variable "load_balancers" {
  type        = list(any)
  default     = []
  description = "The load balancers to couple to the instances. Only used when NOT using ALB"
}

variable "ecs_policy_role_prefix" {
  default     = ""
  description = "The prefix of the parameters this role should be able to access"
}

variable "tg_health_check_port" {
  default     = ""
  description = "port on which to listen to health check from ec2 instance. Default is disabled."
}

variable "key_name" {
  description = "SSH key name to be used"
}

variable "custom_userdata" {
  default     = ""
  description = "Inject extra bash command in the instance template to be run on boot"
}

variable "custom_userdata_directives" {
  default     = ""
  description = "Inject extra cloud-init directives in the instance template to be run on boot. Please visit a doc https://cloudinit.readthedocs.io/en/latest/"
}

variable "node_groups" {
  description = "ECS node group definitions to create"
  type        = any
  default     = {}
}

variable "node_group_defaults" {
  description = "ECS node group default configurations"
  type        = any
  default     = {}
}

variable "capacity_providers" {
  type        = map(any)
  default     = {}
  description = "Configuration of Capacity Providers for ECS cluster autoscaling"
}

variable "ecs_config" {
  default     = "echo '' > /etc/ecs/ecs.config"
  description = "Specify ecs configuration or get it from S3. Example: aws s3 cp s3://some-bucket/ecs.config /etc/ecs/ecs.config"
}

variable "ecs_logging" {
  default     = "[\"json-file\", \"awslogs\", \"none\"]"
  description = "Adding logging option to ECS that the Docker containers can use. It is possible to add fluentd as well"
}

variable "ecs_log_file" {
  default     = ""
  description = "The location where agent logs should be written. If you are running the agent via ecs-init, which is the default method when using the Amazon ECS-optimized AMI, the in-container path will be /log and ecs-init mounts that out to /var/log/ecs/ on the host."
}

variable "ecs_log_level" {
  default     = "info"
  description = "The level of detail to log."
  validation {
    condition     = contains(["crit", "error", "warn", "info", "debug"], var.ecs_log_level)
    error_message = "Available values \"crit\", \"error\", \"warn\", \"info\" or \"debug\"."
  }
}

variable "ecs_reserved_ports" {
  default     = "[22, 2375, 2376, 51678, 51679, 51680]"
  description = "An array of TCP ports that should be marked as unavailable for scheduling on this container instance."
}

variable "ecs_reserved_udp_ports" {
  default     = "[]"
  description = "An array of UDP ports that should be marked as unavailable for scheduling on this container instance."
}

variable "ecs_disable_image_cleanup" {
  default     = "false"
  description = "Whether to disable automated image cleanup for the Amazon ECS agent."
}

variable "ecs_image_cleanup_interval" {
  default     = "30m"
  description = "The time interval between automated image cleanup cycles. If set to less than 10 minutes, the value is ignored."
}

variable "ecs_image_minimum_cleanup_age" {
  default     = "1h"
  description = "The minimum time interval between when an image is pulled and when it can be considered for automated image cleanup."
}

variable "ecs_num_images_delete_per_cycle" {
  default     = "5"
  description = "The maximum number of images to delete in a single automated image cleanup cycle. If set to less than 1, the value is ignored."
}

variable "ecs_image_pull_behavior" {
  default     = "default"
  description = "The behavior used to customize the pull image process for your container instances."
}

variable "ecs_datadir" {
  default     = "/data"
  description = "The name of the persistent data directory on the container that is running the Amazon ECS container agent. The directory is used to save information about the cluster and the agent state."
}

variable "ecs_checkpoint" {
  default     = "true"
  description = "Whether to save the checkpoint state to the location specified with `ECS_DATADIR`."
}

variable "ecs_engine_auth_type" {
  default     = ""
  description = "The type of auth data that is stored in the ECS_ENGINE_AUTH_DATA key."
  validation {
    condition     = contains(["docker", "dockercfg"], var.ecs_engine_auth_type)
    error_message = "Available values \"docker\", \"dockercfg\"."
  }
}

variable "ecs_engine_auth_data" {
  default     = ""
  description = "Docker [auth data](https://pkg.go.dev/github.com/aws/amazon-ecs-agent/agent/dockerclient/dockerauth) formatted as defined by `ECS_ENGINE_AUTH_TYPE`."
}

variable "ecs_container_stop_timeout" {
  default     = "10m"
  description = "Instance scoped configuration for time to wait for the container to exit normally before being forcibly killed."
}

variable "ecs_enable_spot_instance_draining" {
  default     = "false"
  description = "Whether to enable Spot Instance draining for the container instance. If true, if the container instance receives a spot interruption notice, agent will set the instance's status to DRAINING, which gracefully shuts down and replaces all tasks running on the instance that are part of a service."
}

variable "ecs_engine_task_cleanup_wait_duration" {
  default     = "3h"
  description = "Default time to wait to delete containers for a stopped task. If set to less than 1 second, the value is ignored."
}

variable "non_ecs_image_minimum_cleanup_age" {
  default     = "1h"
  description = "The minimum time interval between when a non ECS image is created and when it can be considered for automated image cleanup."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Map of tags to assign to bucket."
}

variable "ecs_services" {
  type        = map(any)
  default     = {}
  description = "Configuration of ECS services running on the cluster"
}

variable "service_discovery_namespaces" {
  type        = map(any)
  default     = {}
  description = "Map of ECS service discovery namespaces."
}
