# Module Terraform pour déployer la fonction Lambda de contact

# Rôle IAM pour Lambda
resource "aws_iam_role" "lambda_contact_role" {
  name = "${var.project_name}-contact-lambda-role"

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

  tags = var.tags
}

# Politique pour les logs CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_contact_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Politique pour SES
resource "aws_iam_role_policy" "lambda_ses" {
  name = "${var.project_name}-lambda-ses-policy"
  role = aws_iam_role.lambda_contact_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      }
    ]
  })
}

# Archive du code Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../lambda"
  output_path = "${path.module}/lambda-contact.zip"
}

# Fonction Lambda
resource "aws_lambda_function" "contact_form" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-contact-form"
  role            = aws_iam_role.lambda_contact_role.arn
  handler         = "contact-form.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime         = "nodejs18.x"
  timeout         = 10
  memory_size     = 256

  environment {
    variables = {
      NODE_ENV = var.environment
    }
  }

  tags = var.tags
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "contact_api" {
  name        = "${var.project_name}-contact-api"
  description = "API pour le formulaire de contact ECOF"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

# Resource /contact
resource "aws_api_gateway_resource" "contact" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id
  parent_id   = aws_api_gateway_rest_api.contact_api.root_resource_id
  path_part   = "contact"
}

# Méthode POST
resource "aws_api_gateway_method" "contact_post" {
  rest_api_id   = aws_api_gateway_rest_api.contact_api.id
  resource_id   = aws_api_gateway_resource.contact.id
  http_method   = "POST"
  authorization = "NONE"
}

# Méthode OPTIONS (CORS)
resource "aws_api_gateway_method" "contact_options" {
  rest_api_id   = aws_api_gateway_rest_api.contact_api.id
  resource_id   = aws_api_gateway_resource.contact.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Intégration Lambda pour POST
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.contact_api.id
  resource_id             = aws_api_gateway_resource.contact.id
  http_method             = aws_api_gateway_method.contact_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.contact_form.invoke_arn
}

# Intégration MOCK pour OPTIONS
resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id
  resource_id = aws_api_gateway_resource.contact.id
  http_method = aws_api_gateway_method.contact_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Réponse OPTIONS
resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id
  resource_id = aws_api_gateway_resource.contact.id
  http_method = aws_api_gateway_method.contact_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

# Intégration réponse OPTIONS
resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id
  resource_id = aws_api_gateway_resource.contact.id
  http_method = aws_api_gateway_method.contact_options.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'" # À restreindre en production
  }

  depends_on = [aws_api_gateway_integration.options_integration]
}

# Permission pour API Gateway d'invoquer Lambda
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contact_form.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.contact_api.execution_arn}/*/*"
}

# Déploiement de l'API
resource "aws_api_gateway_deployment" "contact_deployment" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.contact.id,
      aws_api_gateway_method.contact_post.id,
      aws_api_gateway_method.contact_options.id,
      aws_api_gateway_integration.lambda_integration.id,
      aws_api_gateway_integration.options_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_integration.options_integration
  ]
}

# Stage de l'API
resource "aws_api_gateway_stage" "contact_stage" {
  deployment_id = aws_api_gateway_deployment.contact_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.contact_api.id
  stage_name    = var.environment

  tags = var.tags
}

# CloudWatch Log Group pour Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.contact_form.function_name}"
  retention_in_days = 14

  tags = var.tags
}
