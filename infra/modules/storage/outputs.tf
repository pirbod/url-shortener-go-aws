output "url_map_arn" {
  value       = aws_dynamodb_table.url_map.arn
  description = "ARN of the DynamoDB table"
}

output "table_name" {
  value       = aws_dynamodb_table.url_map.name
  description = "Name of the DynamoDB table"
}
