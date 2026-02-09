output "api_endpoint" {
  description = "URL de l'API Gateway pour le formulaire de contact"
  value       = "${aws_api_gateway_stage.contact_stage.invoke_url}/contact"
}

output "lambda_function_name" {
  description = "Nom de la fonction Lambda"
  value       = aws_lambda_function.contact_form.function_name
}

output "lambda_function_arn" {
  description = "ARN de la fonction Lambda"
  value       = aws_lambda_function.contact_form.arn
}

output "api_gateway_id" {
  description = "ID de l'API Gateway"
  value       = aws_api_gateway_rest_api.contact_api.id
}
