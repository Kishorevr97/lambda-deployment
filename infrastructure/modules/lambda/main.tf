resource "aws_lambda_function" "my_lambda" {
  function_name = "hello-world-function"
  role          = var.lambda_role_arn
  image_uri     = "010928202531.dkr.ecr.us-east-1.amazonaws.com/hackathon/helloworld:latest"
  package_type  = "Image"
  # depends_on    = [var.attach_basic_execution]
  environment {
    variables = {
      NODE_ENV = "production"
    }
  }
}

# resource "aws_lambda_function_url" "function_url" {
#   function_name      = aws_lambda_function.my_lambda.function_name
#   authorization_type = "NONE"  # or "AWS_IAM" for authenticated access
# }

# Create API Gateway
resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "lambda-container-api"
  protocol_type = "HTTP"
  
  cors_configuration {
    allow_origins = ["*"]  # Restrict to your domain in production
    allow_methods = ["GET", "POST", "PUT", "DELETE"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age       = 300
  }
}

# Create API stage
resource "aws_apigatewayv2_stage" "lambda_stage" {
  api_id = aws_apigatewayv2_api.lambda_api.id
  name   = "prod"
  auto_deploy = true
}

# Create API integration with Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id = aws_apigatewayv2_api.lambda_api.id

  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.my_lambda.invoke_arn
}

# Create API route
resource "aws_apigatewayv2_route" "lambda_route" {
  api_id = aws_apigatewayv2_api.lambda_api.id
  route_key = "ANY /{proxy+}"  # Catches all paths
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}
# Allow API Gateway to invoke Lambda
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}
