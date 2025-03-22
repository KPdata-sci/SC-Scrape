

/* EC2 setup */ 

resource "aws_ec2_host" "host_page" {
  ami = 
  availability_zone = var.azs[each.key]
  
}


/* db setuo */ 
resource "aws_dynamodb_table" "songs_table" {
  name           = "Songs"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "SongID"
 
  #This will be used when we set up a direct stream - elasticache/search
  #stream_enabled   = true
  #stream_view_type = "NEW_IMAGE"

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


/* Lambda inti*/
resource "aws_lambda_function" "sc_scraper" {
  function_name = "sc_scraper"
  runtime = "python3.9" 
  handler = "lambda_function.lambda_handler"
  role = aws_iam_role.scraper_lambda_role.arn
  source_code_hash = filebase64sha256("our_botofile.zip")

  environment {
    variables = {
      #TARGET_WEBSITE = "www.soundcloud.com" # Target already localted in lambda (dynamic)
      DYNAMO_TABLE   = aws_dynamodb_table.songs_table.name
    }
  }
}
