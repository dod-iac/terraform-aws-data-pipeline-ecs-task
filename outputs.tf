output "task_definition_arn" {
  description = "The Amazon Resource Name (ARN) of the AWS ECS Task Definition."
  value       = aws_ecs_task_definition.main.arn
}

output "task_definition_family" {
  description = "The family of the AWS ECS Task Definition."
  value       = aws_ecs_task_definition.main.family
}

output "task_definition_revision" {
  description = "The latest revision of the AWS ECS Task Definition."
  value       = aws_ecs_task_definition.main.revision
}
