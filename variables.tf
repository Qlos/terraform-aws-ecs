variable "cloudwatch_prefix" {
  default     = ""
  description = "If you want to avoid cloudwatch collision or you don't want to merge all logs to one log group specify a prefix"
}

variable "name" {
  description = "The name of the cluster"
}

variable "instance_group" {
  default     = "default"
  description = "The name of the instances that you consider as a group"
}

variable "vpc_id" {
  description = "The VPC id"
}

variable "aws_ami" {
  default     = ""
  description = "The AWS ami id to use"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "AWS main type of EC2 instance to use"
}

variable "familiar_instance_types" {
  type        = list
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

variable "private_subnet_ids" {
  type        = list
  description = "The list of private subnets to place the instances in"
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
  type        = list
  description = "Allowed this AWS security groups to ECS cluster. Can be used only with `create_security_group` variable with `false` value."
}

variable "lb_target_group" {
  default = ""
  description = "LoadBalancer target group ARN"
}

variable "load_balancers" {
  type        = list
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

