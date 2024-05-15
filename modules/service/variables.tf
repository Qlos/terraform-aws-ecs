variable "name" {
  type = string
}

variable "capacity_provider_strategy" {
  type    = map(string)
  default = null
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
  type    = map(string)
  default = {}
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
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "container_definitions_template_file" {
  type = string
}

variable "container_definitions_template_vars" {
  type = object(any)
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
  type    = map(string)
  default = {}
}
