variable "name" {
  type = string
}

variable "capacity_provider_strategy" {
  type = list(object({
    capacity_provider = string
    weight            = number
    base              = number
  }))
  description = "The capacity provider strategies to use for the service. See `capacity_provider_strategy` configuration block: https://www.terraform.io/docs/providers/aws/r/ecs_service.html#capacity_provider_strategy"
  default     = []
}

variable "cluster_id" {
  type = string
}

variable "deployment_maximum_percent" {
  type    = number
  default = null
}

variable "deployment_minimum_healthy_percent" {
  type    = number
  default = null
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "enable_execute_command" {
  type    = bool
  default = false
}

variable "health_check_grace_period_seconds" {
  type    = number
  default = null
}

variable "launch_type" {
  type    = string
  default = null
}

variable "wait_for_steady_state" {
  type    = bool
  default = false
}

variable "load_balancer" {
  type = list(object({
    container_name   = string
    container_port   = number
    target_group_arn = string
  }))
  description = "A list of load balancer config objects for the ECS service; see [ecs_service#load_balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#load_balancer) docs"
  default     = []
}

variable "propagate_tags" {
  type    = string
  default = "TASK_DEFINITION"
}

variable "scheduling_strategy" {
  type    = string
  default = "REPLICA"
}

variable "service_subnet_ids" {
  type    = list(string)
  default = []
}

variable "service_security_group_ids" {
  type    = list(string)
  default = null
}

# task definition

variable "task_definition_family" {
  type = string
}

variable "execution_role_arn" {
  type    = string
  default = ""
}

variable "task_role_arn" {
  type    = string
  default = ""
}

variable "container_definitions_template_file" {
  type = string
}

variable "container_definitions_template_vars" {
  type = map(string)
}

variable "network_mode" {
  type    = string
  default = "awsvpc"
}

variable "requires_compatibilities" {
  type    = list(string)
  default = ["EC2"]
}

variable "cpu" {
  type    = string
  default = null
}

variable "memory" {
  type    = string
  default = null
}

variable "skip_destroy" {
  type    = bool
  default = false
}

variable "volumes" {
  type    = list(map(any))
  default = []
}

# common

variable "tags" {
  type    = map(string)
  default = {}
}

# service connect
variable "service_discovery" {
  type    = any
  default = null
}
