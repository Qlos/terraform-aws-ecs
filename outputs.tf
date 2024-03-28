
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
