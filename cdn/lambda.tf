locals {
  lambda_name = "vrs-frontdoor"
  iam_role    = "lambda-role-vrs-${terraform.workspace}"
  iam_policy  = "lambda-policy-vrs-${terraform.workspace}"
}

resource "aws_iam_role" "lambda_role" {
  name               = local.iam_role
  assume_role_policy = data.aws_iam_policy_document.arpd.json
}

resource "aws_cloudwatch_log_group" "lambda_lg" {
  name              = "/aws/lambda/${local.lambda_name}"
  retention_in_days = 14
}

resource "aws_iam_policy" "lambda_policy" {
  name        = local.iam_policy
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_pa" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

data "aws_iam_policy_document" "arpd" {
  statement {
    sid    = "AllowAwsToAssumeRole"
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_lambda_function" "lambda" {
  filename         = "target.zip"
  source_code_hash = filebase64sha256("target.zip")

  function_name = local.lambda_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.10"

  memory_size = 256
  timeout     = 90

  environment {
    variables = {
      ENVIRONMENT      = terraform.workspace
      IS_HTTPS         = "true"
      DOMAIN           = "vulnerability-reporting.service.security.gov.uk"
      URL_PREFIX       = "https://vulnerability-reporting.service.security.gov.uk"
      PHASE_BANNER     = terraform.workspace
      FLASK_ENV        = terraform.workspace
    }
  }
}