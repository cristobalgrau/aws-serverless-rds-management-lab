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
  #   environment {
  #     variables = {
  #       RDS_ENDPOINT = 
  #       DB_USER = 
  #       DB_PASSWORD = 
  #       DB_NAME = 
  #     }
  #   }

  layers = [aws_lambda_layer_version.example.arn]

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.private-lambda-logs,
  ]
}


# Created lambda layer for pymysql Python library
resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "python_layer_pymysql.zip"
  layer_name = "mypymysql"

  compatible_runtimes = ["python3.9"]
}

# Created role for lambda functions
resource "aws_iam_role" "iam_for_lambda" {
  name               = "RDS-project-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

