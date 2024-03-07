# backward compatibility
output "default_alb_target_group" {
  value = var.lb_target_group
}

output "default_lb_target_group" {
  value = var.lb_target_group
}

output "ecs_instance_security_group_id" {
  value = local.ecs_security_group_id
}