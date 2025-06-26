resource "aws_dynamodb_table" "url_map" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "code"

  attribute {
    name = "code"
    type = "S"
  }

  tags = { Environment = var.env }
}
