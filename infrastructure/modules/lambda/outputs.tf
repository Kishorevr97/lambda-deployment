output "api_gateway_url" {
  value = aws_apigatewayv2_stage.lambda_stage.invoke_url
}

output "api_gateway_url1" {
  value = aws_apigatewayv2_api.lambda_api.api_endpoint
}

