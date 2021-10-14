/**
 * ## Usage
 *
 * This example is used by the `TestTerraformSimpleExample` test in `test/terrafrom_aws_simple_test.go`.
 *
 * ## Terraform Version
 *
 * This test was created for Terraform 0.13.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

module "s3_bucket_source" {
  source  = "dod-iac/s3-bucket/aws"
  version = "1.0.1"

  name = format("test-src-%s", var.test_name)
  tags = var.tags
}

module "s3_bucket_destination" {
  source  = "dod-iac/s3-bucket/aws"
  version = "1.0.1"

  name = format("test-dst-%s", var.test_name)
  tags = var.tags
}

module "cloudwatch_kms_key" {
  source  = "dod-iac/cloudwatch-kms-key/aws"
  version = "1.0.0"

  name = format("alias/test-cloudwatch-logs-%s", var.test_name)

  tags = var.tags
}

# Create CloudWatch log group outside of module for easier persistence if task is no longer used

resource "aws_cloudwatch_log_group" "ecs_task" {
  name              = format("/aws/ecs/test-%s", var.test_name)
  retention_in_days = 1 # expire logs after 1 day
  kms_key_id        = module.cloudwatch_kms_key.aws_kms_key_arn

  tags = var.tags
}

module "data_pipeline_ecs_task" {
  source = "../../"

  cloudwatch_log_group_name = aws_cloudwatch_log_group.ecs_task.name

  entryPoint               = ["python3"]
  command                  = ["--version"]
  execution_role_name      = format("test-execution-role-%s", var.test_name)
  image                    = "python:3.9-buster"
  memory                   = 8192
  name                     = format("test-%s", var.test_name)
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  s3_buckets_read          = [module.s3_bucket_source.arn]
  s3_buckets_write         = [module.s3_bucket_destination.arn]
  tags                     = var.tags
  task_role_name           = format("test-role-%s", var.test_name)
}
