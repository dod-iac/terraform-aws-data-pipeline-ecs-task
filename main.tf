/**
 * ## Usage
 *
 * Creates the resources to run an ECS task as part of a data pipeline, including an IAM policy, task definition, task execution role, and task role.
 *
 * ```hcl
 *
 * resource "aws_cloudwatch_log_group" "ecs_task" {
 *   name              = format("/aws/ecs/app-%s-task-%s", var.application, var.environment)
 *   retention_in_days = 1 # expire logs after 1 day
 *   tags = var.tags
 * }
 *
 * module "data_pipeline_ecs_task" {
 *   source = "dod-iac/data-pipeline-ecs-task/aws"
 *
 *   cloudwatch_log_group_name = aws_cloudwatch_log_group.ecs_task.name
 *   command = ["help"]
 *   entryPoint = ["/entrypoint.sh"]
 *   execution_role_name = format("app-%s-ecs-execution-role-%s", var.application, var.environment)
 *   image = var.image
 *   memory = pow(2, 5)
 *   name = format("app-%s-task-%s", var.application, var.environment)
 *   s3_buckets_read = [aws_s3_bucket.source.arn]
 *   s3_buckets_write = [aws_s3_bucket.destination.arn]
 *   tags = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 *   task_role_name = format("app-%s-ecs-task-role-%s", var.application, var.environment)
 * }
 * ```
 *
 * ## Testing
 *
 * Run all terratest tests using the `terratest` script.  If using `aws-vault`, you could use `aws-vault exec $AWS_PROFILE -- terratest`.  The `AWS_DEFAULT_REGION` environment variable is required by the tests.  Use `TT_SKIP_DESTROY=1` to not destroy the infrastructure created during the tests.  Use `TT_VERBOSE=1` to log all tests as they are run.  Use `TT_TIMEOUT` to set the timeout for the tests, with the value being in the Go format, e.g., 15m.  Use `TT_TEST_NAME` to run a specific test by name.
 *
 * ## Terraform Version
 *
 * Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to main branch.
 *
 * Terraform 0.11 and 0.12 are not supported.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */
data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

module "execution_role" {
  #source  = "dod-iac/ecs-task-execution-role/aws"
  #version = "1.0.1"
  source = "github.com/dod-iac/terraform-aws-ecs-task-execution-role?ref=update_4_0"

  allow_create_log_groups    = true
  allow_ecr                  = true
  cloudwatch_log_group_names = [var.cloudwatch_log_group_name]
  name                       = var.execution_role_name
  policy_name                = length(var.execution_role_policy_name) > 0 ? var.execution_role_policy_name : var.execution_role_name
  policy_document            = length(var.execution_role_policy_document) > 0 ? var.execution_role_policy_document : ""
  tags                       = var.tags
}

module "task_role" {
  #source  = "dod-iac/ecs-task-role/aws"
  #version = "1.0.1"
  source = "github.com/dod-iac/terraform-aws-ecs-task-role?ref=update_4_0"

  name = var.task_role_name
  tags = var.tags
}

module "task_role_policy" {
  #source  = "dod-iac/data-pipeline-iam-policy/aws"
  #version = "1.0.1"
  source = "github.com/dod-iac/terraform-aws-data-pipeline-iam-policy?ref=update_4_0"

  glue_tables_add  = var.glue_tables_add
  kms_keys_decrypt = var.kms_keys_decrypt
  kms_keys_encrypt = var.kms_keys_encrypt
  name             = length(var.task_role_policy_name) > 0 ? var.task_role_policy_name : var.task_role_name
  s3_buckets_read  = var.s3_buckets_read
  s3_buckets_write = var.s3_buckets_write
}

resource "aws_iam_role_policy_attachment" "task_role" {
  role       = module.task_role.name
  policy_arn = module.task_role_policy.arn
}

resource "aws_ecs_task_definition" "main" {
  container_definitions = jsonencode([
    {
      entryPoint = var.entryPoint
      command    = var.command
      # You can determine the number of CPU units that are available
      # per Amazon EC2 instance type by multiplying the number of vCPUs
      # listed for that instance type on the Amazon EC2 Instances detail page by 1,024.
      cpu         = var.cpu # cpu reservation
      environment = []
      essential   = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.cloudwatch_log_group_name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = var.name
        }
      }
      memory                 = var.memory
      mountPoints            = []
      name                   = var.name
      image                  = var.image
      portMappings           = []
      readonlyRootFilesystem = var.readonlyRootFilesystem
      stopTimeout            = 5
      volumesFrom            = []
    }
  ])
  cpu                      = contains(var.requires_compatibilities, "FARGATE") ? var.cpu : null
  execution_role_arn       = module.execution_role.arn
  family                   = var.name
  memory                   = contains(var.requires_compatibilities, "FARGATE") ? var.memory : null
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  tags                     = var.tags
  task_role_arn            = module.task_role.arn
}
