<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Usage

Creates the resources to run an ECS task as part of a data pipeline, including an IAM policy, task definition, task execution role, and task role.

```hcl

resource "aws_cloudwatch_log_group" "ecs_task" {
  name              = format("/aws/ecs/app-%s-task-%s", var.application, var.environment)
  retention_in_days = 1 # expire logs after 1 day
  tags = var.tags
}

module "data_pipeline_ecs_task" {
  source = "dod-iac/data-pipeline-ecs-task/aws"

  cloudwatch_log_group_name = aws_cloudwatch_log_group.ecs_task.name
  command = ["help"]
  entryPoint = ["/entrypoint.sh"]
  execution_role_name = format("app-%s-ecs-execution-role-%s", var.application, var.environment)
  image = var.image
  memory = pow(2, 5)
  name = format("app-%s-task-%s", var.application, var.environment)
  s3_buckets_read = [aws_s3_bucket.source.arn]
  s3_buckets_write = [aws_s3_bucket.destination.arn]
  tags = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
  task_role_name = format("app-%s-ecs-task-role-%s", var.application, var.environment)
}
```

## Testing

Run all terratest tests using the `terratest` script.  If using `aws-vault`, you could use `aws-vault exec $AWS_PROFILE -- terratest`.  The `AWS_DEFAULT_REGION` environment variable is required by the tests.  Use `TT_SKIP_DESTROY=1` to not destroy the infrastructure created during the tests.  Use `TT_VERBOSE=1` to log all tests as they are run.  Use `TT_TIMEOUT` to set the timeout for the tests, with the value being in the Go format, e.g., 15m.  Use `TT_TEST_NAME` to run a specific test by name.

## Terraform Version

Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to main branch.

Terraform 0.11 and 0.12 are not supported.

## License

This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0, < 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_execution_role"></a> [execution\_role](#module\_execution\_role) | dod-iac/ecs-task-execution-role/aws | 1.0.0 |
| <a name="module_task_role"></a> [task\_role](#module\_task\_role) | dod-iac/ecs-task-role/aws | 1.0.0 |
| <a name="module_task_role_policy"></a> [task\_role\_policy](#module\_task\_role\_policy) | dod-iac/data-pipeline-iam-policy/aws | 1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_task_definition.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role_policy_attachment.task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | The name of the CloudWatch log group that the ECS task sends logs to. | `string` | n/a | yes |
| <a name="input_command"></a> [command](#input\_command) | The command to use with the task. | `list(string)` | n/a | yes |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Number of cpu units used by the task. If the requires\_compatibilities is FARGATE this field is required. | `number` | `4096` | no |
| <a name="input_entryPoint"></a> [entryPoint](#input\_entryPoint) | The entry point to use with the ECS task. | `list(string)` | n/a | yes |
| <a name="input_execution_role_name"></a> [execution\_role\_name](#input\_execution\_role\_name) | The name of the IAM execution role used by the ECS task. | `string` | n/a | yes |
| <a name="input_execution_role_policy_document"></a> [execution\_role\_policy\_document](#input\_execution\_role\_policy\_document) | The contents of the IAM policy attached to the IAM execution role used by the ECS task.  If not defined, then creates the policy with permissions to log to CloudWatch Logs. | `string` | `""` | no |
| <a name="input_execution_role_policy_name"></a> [execution\_role\_policy\_name](#input\_execution\_role\_policy\_name) | The name of the IAM policy attached to the IAM Execution role used by the ECS task.  If not defined, then uses the value of "execution\_role\_name". | `string` | `""` | no |
| <a name="input_glue_tables_add"></a> [glue\_tables\_add](#input\_glue\_tables\_add) | List of glue tables that partitions can be added to. | <pre>list(object({<br>    database = string<br>    table    = string<br>  }))</pre> | `[]` | no |
| <a name="input_image"></a> [image](#input\_image) | The image for the essential container of the ECS task. | `string` | n/a | yes |
| <a name="input_kms_keys_decrypt"></a> [kms\_keys\_decrypt](#input\_kms\_keys\_decrypt) | The ARNs of the AWS KMS keys that can be used to decrypt data.  Use ["*"] to allow all keys. | `list(string)` | `[]` | no |
| <a name="input_kms_keys_encrypt"></a> [kms\_keys\_encrypt](#input\_kms\_keys\_encrypt) | The ARNs of the AWS KMS keys that can be used to encrypt data.  Use ["*"] to allow all keys. | `list(string)` | `[]` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The memory allocated to the ECS task. | `number` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the ECS task definition, essential container, and CloudWatch stream name. | `string` | n/a | yes |
| <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode) | The Docker networking mode to use for the task.  Valid values are none, bridge, awsvpc, and host. | `string` | `"awsvpc"` | no |
| <a name="input_readonlyRootFilesystem"></a> [readonlyRootFilesystem](#input\_readonlyRootFilesystem) | If true, then the container's root filesystem is mounted as read only. | `bool` | `false` | no |
| <a name="input_requires_compatibilities"></a> [requires\_compatibilities](#input\_requires\_compatibilities) | Set of launch types required by the task. The valid values are EC2 and FARGATE. | `list(string)` | <pre>[<br>  "EC2",<br>  "FARGATE"<br>]</pre> | no |
| <a name="input_s3_buckets_read"></a> [s3\_buckets\_read](#input\_s3\_buckets\_read) | The ARNs of the AWS S3 buckets that can be read from.  Use ["*"] to allow all buckets. | `list(string)` | `[]` | no |
| <a name="input_s3_buckets_write"></a> [s3\_buckets\_write](#input\_s3\_buckets\_write) | The ARNs of the AWS S3 buckets that can be written to.  Use ["*"] to allow all buckets. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resources. | `map(string)` | `{}` | no |
| <a name="input_task_role_name"></a> [task\_role\_name](#input\_task\_role\_name) | The name of the IAM task role used by the ECS task. | `string` | n/a | yes |
| <a name="input_task_role_policy_document"></a> [task\_role\_policy\_document](#input\_task\_role\_policy\_document) | The contents of the IAM policy attached to the IAM Execution role used by the ECS task.  If not defined, then creates a blank policy. | `string` | `""` | no |
| <a name="input_task_role_policy_name"></a> [task\_role\_policy\_name](#input\_task\_role\_policy\_name) | The name of the IAM policy attached to the task role used by the ECS task.  If not defined, then uses the value of "task\_role\_name". | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | The Amazon Resource Name (ARN) of the AWS ECS Task Definition. |
| <a name="output_task_definition_family"></a> [task\_definition\_family](#output\_task\_definition\_family) | The family of the AWS ECS Task Definition. |
| <a name="output_task_definition_revision"></a> [task\_definition\_revision](#output\_task\_definition\_revision) | The latest revision of the AWS ECS Task Definition. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
