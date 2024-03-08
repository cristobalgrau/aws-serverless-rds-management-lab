# ==== LAMBDA SECTION ====

# Created Lambda function for Private RDS
resource "aws_lambda_function" "private-lambda" {
  filename      = "${path.module}/lambda/lambda_function_payload.zip"
  function_name = var.private-lambda-name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.9"

  # ENV VARS for Lambda
    environment {
      variables = {
        RDS_ENDPOINT = aws_db_instance.rds-private.address
        DB_USER = var.db-username
        DB_PASSWORD = var.db_pass
        DB_NAME = var.db-name
      }
    }

  vpc_config {
    subnet_ids         = [for subnet_key, subnet_value in aws_subnet.private_subnets : subnet_value.id]
    security_group_ids = [aws_default_security_group.default.id]
  }

  layers = [aws_lambda_layer_version.lambda_layer.arn]
}

# Created Lambda function for Public RDS
resource "aws_lambda_function" "public-lambda" {
  filename      = "${path.module}/lambda/lambda_function_payload.zip"
  function_name = var.public-lambda-name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.9"

  # ENV VARS for Lambda
  #   environment {
  #     variables = {
  #       RDS_ENDPOINT = 
  #       DB_USER = 
  #       DB_PASSWORD = 
  #       DB_NAME = 
  #     }
  #   }

  layers = [aws_lambda_layer_version.lambda_layer.arn]
}

# Created lambda layer for pymysql Python library
resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "${path.module}/lambda/python_layer_pymysql.zip"
  layer_name = "mypymysql"

  compatible_runtimes = ["python3.9"]
}

# Created role for lambda functions
resource "aws_iam_role" "iam_for_lambda" {
  name               = "RDS-project-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attached VPC management policy to the lambda role
resource "aws_iam_role_policy_attachment" "attach-vpc-policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = data.aws_iam_policy.vpc-management.arn
}
