resource "aws_dynamodb_table" "songs_table" {
  name           = "Songs"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "SongID"

  attribute {
    name = "SongID"
    type = "S"
  }

  tags = {
    Environment = "dev"
    Application = "SC-Scrape"
  }
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.songs_table.name
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.songs_table.arn
}