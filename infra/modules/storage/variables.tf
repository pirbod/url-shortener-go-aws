variable "table_name" {
  type        = string
  description = "DynamoDB table name"
}

variable "env" {
  type        = string
  description = "Environment (dev or prod)"
}
