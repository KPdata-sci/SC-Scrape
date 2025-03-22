# IAM Policy for Lambda to write to DynamoDB
resource "aws_iam_policy" "lambda_dynamodb_write_policy" {
  name        = "LambdaDynamoDBWritePolicy"
  description = "Allows Lambda to write JSON payloads to a DynamoDB table"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowDynamoDBWriteAccess"
        Effect   = "Allow"
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = aws_dynamodb_table.songs_table.arn
      }
    ]
  })
}

# Scraper IAM Role
resource "aws_iam_role" "scraper_lambda_role" {
  name = "scraper_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "scraper_dynamo" {
  role       = aws_iam_role.scraper_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_execution_role" {
  name = "LambdaDynamoDBWriteRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda to write logs to CloudWatch
resource "aws_iam_policy" "lambda_logs_policy" {
  name        = "LambdaLogsPolicy"
  description = "Allows Lambda to write logs to CloudWatch"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowCloudWatchLogs"
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach Lambda DynamoDB Write Policy to Lambda Execution Role
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_write_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_write_policy.arn
}

# Attach Lambda Logs Policy to Lambda Execution Role
resource "aws_iam_role_policy_attachment" "lambda_logs_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_logs_policy.arn
}

# IAM Policy for EC2 to access DynamoDB
resource "aws_iam_policy" "web_db_iam_policy" {
  name = "DynamoDBAccessPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowDynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:PutItem"
        ]
        Resource = aws_dynamodb_table.songs_table.arn
      }
    ]
  })
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "EC2DynamoDBAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach DynamoDB Access Policy to EC2 Role
resource "aws_iam_role_policy_attachment" "ec2_dynamodb_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.web_db_iam_policy.arn
}

# Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "ec2-security-group"
  description = "Security group for EC2 instance"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#API Gateway?


/*
resource "aws_security_group" "allow_https" {
  name = "allow https"
  
  ingress =  {
  from_port =  80
  to_port = 80
  protocool = tcp
  cidr_block = ["0.0.0.0/0"] 
  } 
 
  egress = {
    from_port = 22
    to_port = 22
    protocool = -1
    cidr_block = ["0.0.0.0/0"]
  }
}
*/


