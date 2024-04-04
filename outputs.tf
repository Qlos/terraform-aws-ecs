
output "cluster_arn" {
  description = "ARN that identifies the cluster"
  value       = try(aws_ecs_cluster.this.arn, null)
}

output "cluster_id" {
  description = "ID that identifies the cluster"
  value       = try(aws_ecs_cluster.this.id, null)
}

output "cluster_name" {
  description = "Name that identifies the cluster"
  value       = try(aws_ecs_cluster.this.name, null)
}

output "cloudwatch_log_group_name" {
  description = "Name of CloudWatch log group created"
  value       = try(aws_cloudwatch_log_group.cluster[0].name, null)
}

output "cloudwatch_log_group_arn" {
  description = "ARN of CloudWatch log group created"
  value       = try(aws_cloudwatch_log_group.cluster[0].arn, null)
}

output "node_groups" {
  description = "Map of attribute maps for all ECS node groups created"
  value       = module.node_group
}

output "node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by ECS node groups"
  value       = compact([for group in module.node_group : group.autoscaling_group_name])
}

output "node_groups_autoscaling_group_arns" {
  description = "List of the ARNs for this autoscaling group"
  value       = compact([for group in module.node_group : group.autoscaling_group_arn])
}

output "node_groups_autoscaling_group_ids" {
  description = "List of the autoscaling group ids"
  value       = compact([for group in module.node_group : group.autoscaling_group_id])
}

output "node_groups_launch_template_ids" {
  description = "List of the IDs of the launch templates"
  value       = compact([for group in module.node_group : group.launch_template_id])
}

output "node_groups_launch_template_arns" {
  description = "List of the ARNs of the launch templates"
  value       = compact([for group in module.node_group : group.launch_template_arn])
}

output "node_groups_launch_template_names" {
  description = "List of the names of the launch templates"
  value       = compact([for group in module.node_group : group.launch_template_name])
}
