variable "cloudwatch_log_group_name" {
  type        = string
  description = "The name of the CloudWatch log group that the ECS task sends logs to."
}

variable "command" {
  type        = list(string)
  description = "The command to use with the task."
}

variable "cpu" {
  type        = number
  description = "Number of cpu units used by the task. If the requires_compatibilities is FARGATE this field is required."
  default     = 4096
}

variable "entryPoint" {
  type        = list(string)
  description = "The entry point to use with the ECS task."
}

variable "execution_role_name" {
  type        = string
  description = "The name of the IAM execution role used by the ECS task."
}

variable "execution_role_policy_document" {
  type        = string
  description = "The contents of the IAM policy attached to the IAM execution role used by the ECS task.  If not defined, then creates the policy with permissions to log to CloudWatch Logs."
  default     = ""
}

variable "execution_role_policy_name" {
  type        = string
  description = "The name of the IAM policy attached to the IAM Execution role used by the ECS task.  If not defined, then uses the value of \"execution_role_name\"."
  default     = ""
}

variable "glue_tables_add" {
  type = list(object({
    database = string
    table    = string
  }))
  description = "List of glue tables that partitions can be added to."
  default     = []
}

variable "image" {
  type        = string
  description = "The image for the essential container of the ECS task."
}

variable "kms_keys_decrypt" {
  type        = list(string)
  description = "The ARNs of the AWS KMS keys that can be used to decrypt data.  Use [\"*\"] to allow all keys."
  default     = []
}

variable "kms_keys_encrypt" {
  type        = list(string)
  description = "The ARNs of the AWS KMS keys that can be used to encrypt data.  Use [\"*\"] to allow all keys."
  default     = []
}

variable "network_mode" {
  type        = string
  description = "The Docker networking mode to use for the task.  Valid values are none, bridge, awsvpc, and host."
  default     = "awsvpc"
}

variable "memory" {
  type        = number
  description = "The memory allocated to the ECS task."
}

variable "task_role_name" {
  type        = string
  description = "The name of the IAM task role used by the ECS task."
}

variable "task_role_policy_document" {
  type        = string
  description = "The contents of the IAM policy attached to the IAM Execution role used by the ECS task.  If not defined, then creates a blank policy."
  default     = ""
}

variable "task_role_policy_name" {
  type        = string
  description = "The name of the IAM policy attached to the task role used by the ECS task.  If not defined, then uses the value of \"task_role_name\"."
  default     = ""
}

variable "name" {
  type        = string
  description = "The name of the ECS task definition, essential container, and CloudWatch stream name."
}

variable "readonlyRootFilesystem" {
  type        = bool
  description = "If true, then the container's root filesystem is mounted as read only."
  default     = false
}

variable "requires_compatibilities" {
  type        = list(string)
  description = "Set of launch types required by the task. The valid values are EC2 and FARGATE."
  default     = ["EC2", "FARGATE"]
}

variable "s3_buckets_write" {
  type        = list(string)
  description = "The ARNs of the AWS S3 buckets that can be written to.  Use [\"*\"] to allow all buckets."
  default     = []
}

variable "s3_buckets_read" {
  type        = list(string)
  description = "The ARNs of the AWS S3 buckets that can be read from.  Use [\"*\"] to allow all buckets."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources."
  default     = {}
}
