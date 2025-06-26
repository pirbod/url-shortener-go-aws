output "execution_role_arn" {
  value       = aws_iam_role.ecs_execution.arn
  description = "ECS execution role ARN"
}

output "task_role_arn" {
  value       = aws_iam_role.ecs_task.arn
  description = "ECS task role ARN"
}
