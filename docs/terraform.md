<!-- BEGIN_TF_DOCS -->
## Documentation


### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [aws_autoscaling_attachment.asg_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_attachment) | resource |
| [aws_autoscaling_attachment.asg_spot_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_attachment) | resource |
| [aws_autoscaling_group.asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_group.asg_spot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_cloudwatch_event_rule.ecs_task_stopped](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.event_fired](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.audit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.dmesg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.docker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.ecs-agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.ecs-init](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.messages](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_iam_instance_profile.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.ecs_default_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ecs_execution_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.ecs_default_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_policy_attachment.ecs_execution_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.ecs_default_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_execution_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_lb_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_ec2_cloudwatch_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_ec2_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.alb_to_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allowed_sgs_to_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ecs_health_check_for_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.outbound_internet_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_sns_topic.ecs_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_ami.latest_ecs_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current_event_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.current_role_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current_event_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_region.current_role_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [template_file.ecs_task_stopped](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.policy](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.user_data](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_security_group_id"></a> [alb\_security\_group\_id](#input\_alb\_security\_group\_id) | ALB security group id. Can be used only with `create_security_group` variable with `false` value. | `string` | `""` | no |
| <a name="input_allowed_security_group_ids"></a> [allowed\_security\_group\_ids](#input\_allowed\_security\_group\_ids) | Allowed this AWS security groups to ECS cluster. Can be used only with `create_security_group` variable with `false` value. | `list` | `[]` | no |
| <a name="input_associated_security_group_id"></a> [associated\_security\_group\_id](#input\_associated\_security\_group\_id) | Variable to use only with `associated_security_group_id` variable. This security group will be assigned to the ecs cluster instead of creating a new page | `string` | `""` | no |
| <a name="input_aws_ami"></a> [aws\_ami](#input\_aws\_ami) | The AWS ami id to use | `string` | `""` | no |
| <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings) | Specify volumes to attach to the instance besides the volumes specified by the AMI | `any` | `{}` | no |
| <a name="input_cloudwatch_prefix"></a> [cloudwatch\_prefix](#input\_cloudwatch\_prefix) | If you want to avoid cloudwatch collision or you don't want to merge all logs to one log group specify a prefix | `string` | `""` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Create internal AWS SG for ECS cluster. If value is set to `false` you need set up the `associated_security_group_id` variable. | `bool` | `true` | no |
| <a name="input_custom_userdata"></a> [custom\_userdata](#input\_custom\_userdata) | Inject extra bash command in the instance template to be run on boot | `string` | `""` | no |
| <a name="input_custom_userdata_directives"></a> [custom\_userdata\_directives](#input\_custom\_userdata\_directives) | Inject extra cloud-init directives in the instance template to be run on boot. Please visit a doc https://cloudinit.readthedocs.io/en/latest/ | `string` | `""` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | The desired capacity of the cluster | `number` | `1` | no |
| <a name="input_ecs_checkpoint"></a> [ecs\_checkpoint](#input\_ecs\_checkpoint) | Whether to save the checkpoint state to the location specified with `ECS_DATADIR`. | `string` | `"true"` | no |
| <a name="input_ecs_config"></a> [ecs\_config](#input\_ecs\_config) | Specify ecs configuration or get it from S3. Example: aws s3 cp s3://some-bucket/ecs.config /etc/ecs/ecs.config | `string` | `"echo '' > /etc/ecs/ecs.config"` | no |
| <a name="input_ecs_container_stop_timeout"></a> [ecs\_container\_stop\_timeout](#input\_ecs\_container\_stop\_timeout) | Instance scoped configuration for time to wait for the container to exit normally before being forcibly killed. | `string` | `"10m"` | no |
| <a name="input_ecs_datadir"></a> [ecs\_datadir](#input\_ecs\_datadir) | The name of the persistent data directory on the container that is running the Amazon ECS container agent. The directory is used to save information about the cluster and the agent state. | `string` | `"/data"` | no |
| <a name="input_ecs_disable_image_cleanup"></a> [ecs\_disable\_image\_cleanup](#input\_ecs\_disable\_image\_cleanup) | Whether to disable automated image cleanup for the Amazon ECS agent. | `string` | `"false"` | no |
| <a name="input_ecs_enable_spot_instance_draining"></a> [ecs\_enable\_spot\_instance\_draining](#input\_ecs\_enable\_spot\_instance\_draining) | Whether to enable Spot Instance draining for the container instance. If true, if the container instance receives a spot interruption notice, agent will set the instance's status to DRAINING, which gracefully shuts down and replaces all tasks running on the instance that are part of a service. | `string` | `"false"` | no |
| <a name="input_ecs_engine_task_cleanup_wait_duration"></a> [ecs\_engine\_task\_cleanup\_wait\_duration](#input\_ecs\_engine\_task\_cleanup\_wait\_duration) | Default time to wait to delete containers for a stopped task. If set to less than 1 second, the value is ignored. | `string` | `"3h"` | no |
| <a name="input_ecs_image_cleanup_interval"></a> [ecs\_image\_cleanup\_interval](#input\_ecs\_image\_cleanup\_interval) | The time interval between automated image cleanup cycles. If set to less than 10 minutes, the value is ignored. | `string` | `"30m"` | no |
| <a name="input_ecs_image_minimum_cleanup_age"></a> [ecs\_image\_minimum\_cleanup\_age](#input\_ecs\_image\_minimum\_cleanup\_age) | The minimum time interval between when an image is pulled and when it can be considered for automated image cleanup. | `string` | `"1h"` | no |
| <a name="input_ecs_image_pull_behavior"></a> [ecs\_image\_pull\_behavior](#input\_ecs\_image\_pull\_behavior) | The behavior used to customize the pull image process for your container instances. | `string` | `"default"` | no |
| <a name="input_ecs_log_file"></a> [ecs\_log\_file](#input\_ecs\_log\_file) | The location where agent logs should be written. If you are running the agent via ecs-init, which is the default method when using the Amazon ECS-optimized AMI, the in-container path will be /log and ecs-init mounts that out to /var/log/ecs/ on the host. | `string` | `""` | no |
| <a name="input_ecs_log_level"></a> [ecs\_log\_level](#input\_ecs\_log\_level) | The level of detail to log. | `string` | `"info"` | no |
| <a name="input_ecs_logging"></a> [ecs\_logging](#input\_ecs\_logging) | Adding logging option to ECS that the Docker containers can use. It is possible to add fluentd as well | `string` | `"[\"json-file\", \"awslogs\", \"none\"]"` | no |
| <a name="input_ecs_num_images_delete_per_cycle"></a> [ecs\_num\_images\_delete\_per\_cycle](#input\_ecs\_num\_images\_delete\_per\_cycle) | The maximum number of images to delete in a single automated image cleanup cycle. If set to less than 1, the value is ignored. | `string` | `"5"` | no |
| <a name="input_ecs_policy_role_prefix"></a> [ecs\_policy\_role\_prefix](#input\_ecs\_policy\_role\_prefix) | The prefix of the parameters this role should be able to access | `string` | `""` | no |
| <a name="input_ecs_reserved_ports"></a> [ecs\_reserved\_ports](#input\_ecs\_reserved\_ports) | An array of TCP ports that should be marked as unavailable for scheduling on this container instance. | `string` | `"[22, 2375, 2376, 51678, 51679, 51680]"` | no |
| <a name="input_ecs_reserved_udp_ports"></a> [ecs\_reserved\_udp\_ports](#input\_ecs\_reserved\_udp\_ports) | An array of UDP ports that should be marked as unavailable for scheduling on this container instance. | `string` | `"[]"` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Enables/disables detailed monitoring | `bool` | `true` | no |
| <a name="input_familiar_instance_types"></a> [familiar\_instance\_types](#input\_familiar\_instance\_types) | Used only with `spot_instance` variable. List of familiar instance types to use with lowest weight from `instance_type` | `list` | <pre>[<br>  "t3.large",<br>  "m5.large",<br>  "c5.xlarge"<br>]</pre> | no |
| <a name="input_instance_group"></a> [instance\_group](#input\_instance\_group) | The name of the instances that you consider as a group | `string` | `"default"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | AWS main type of EC2 instance to use | `string` | `"t2.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | SSH key name to be used | `any` | n/a | yes |
| <a name="input_lb_target_group"></a> [lb\_target\_group](#input\_lb\_target\_group) | LoadBalancer target group ARN | `string` | `""` | no |
| <a name="input_load_balancers"></a> [load\_balancers](#input\_load\_balancers) | The load balancers to couple to the instances. Only used when NOT using ALB | `list` | `[]` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Maximum size of the nodes in the cluster | `number` | `1` | no |
| <a name="input_metadata_options"></a> [metadata\_options](#input\_metadata\_options) | Customize the metadata options for the instance | `map(string)` | <pre>{<br>  "http_endpoint": "enabled",<br>  "http_put_response_hop_limit": 2,<br>  "http_tokens": "optional"<br>}</pre> | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Minimum size of the nodes in the cluster | `number` | `1` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the cluster | `any` | n/a | yes |
| <a name="input_non_ecs_image_minimum_cleanup_age"></a> [non\_ecs\_image\_minimum\_cleanup\_age](#input\_non\_ecs\_image\_minimum\_cleanup\_age) | The minimum time interval between when a non ECS image is created and when it can be considered for automated image cleanup. | `string` | `"1h"` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | The list of private subnets to place the instances in | `list` | n/a | yes |
| <a name="input_spot_instances"></a> [spot\_instances](#input\_spot\_instances) | Enable or disable spot instances | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to bucket. | `map(string)` | `{}` | no |
| <a name="input_tg_health_check_port"></a> [tg\_health\_check\_port](#input\_tg\_health\_check\_port) | port on which to listen to health check from ec2 instance. Default is disabled. | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC id | `any` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_alb_target_group"></a> [default\_alb\_target\_group](#output\_default\_alb\_target\_group) | backward compatibility |
| <a name="output_default_lb_target_group"></a> [default\_lb\_target\_group](#output\_default\_lb\_target\_group) | n/a |
| <a name="output_ecs_instance_security_group_id"></a> [ecs\_instance\_security\_group\_id](#output\_ecs\_instance\_security\_group\_id) | n/a |

<!-- END_TF_DOCS -->