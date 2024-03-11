# ==== LAMBDA SECTION ====

# ----> LAMBDA SECTION FOR PRIVATE RDS <----

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
      DB_USER      = var.db-username
      DB_PASSWORD  = var.db_pass
      DB_NAME      = var.db-name
    }
  }

  vpc_config {
    subnet_ids         = [for subnet_key, subnet_value in aws_subnet.private_subnets : subnet_value.id]
    security_group_ids = [aws_security_group.allow-rds-to-lambda.id]
  }

  layers = [aws_lambda_layer_version.lambda_layer.arn]
}

# Create Security Group to allow Cconnection between Lamda and RDS
resource "aws_security_group" "allow-rds-to-lambda" {
  name        = "lambda-rds-connect"
  description = "Allow outbound traffic from lambda to RDS"
  vpc_id      = aws_vpc.vpc.id
}

# Created ingress rule for all traffic from Lambda to RDS
resource "aws_vpc_security_group_egress_rule" "allow-rds-to-lambda" {
  security_group_id            = aws_security_group.allow-rds-to-lambda.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.allow-lambda-to-rds.id
}

# ----> LAMBDA SECTION FOR PUBLIC RDS <----

# Created Lambda function for Public RDS
resource "aws_lambda_function" "public-lambda" {
  filename      = "${path.module}/lambda/lambda_function_payload.zip"
  function_name = var.public-lambda-name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.9"

  # ENV VARS for Lambda
  environment {
    variables = {
      RDS_ENDPOINT = aws_db_instance.rds-public.address
      DB_USER      = var.db-username
      DB_PASSWORD  = var.db_pass
      DB_NAME      = var.db-name
    }
  }

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
