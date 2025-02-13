resource "aws_lambda_function" "my_lambda" {
  function_name = "hello-world-function"
  role          = var.lambda_role_arn
  image_uri     = "${var.ecr_repository_url}:latest"
  package_type  = "Image"
 
  environment {
    variables = {
      NODE_ENV = "production"
    }
  }
}


# Create Cognito User Pool
resource "aws_cognito_user_pool" "user_pool" {
  name = "hello-world-user-pool"
}

# Create Cognito App Client
resource "aws_cognito_user_pool_client" "user_pool_client" {
  name = "app-client"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  generate_secret = false
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes = ["openid", "email", "profile"]
  callback_urls = ["${aws_apigatewayv2_api.lambda_api.api_endpoint}/callback"]
  supported_identity_providers = ["COGNITO"]
}


# Create Cognito JWT Authorizer for API Gateway
resource "aws_apigatewayv2_authorizer" "cognito_auth" {
  api_id = aws_apigatewayv2_api.lambda_api.id
  name   = "CognitoAuth"
  authorizer_type = "JWT"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    issuer  = "https://cognito-idp.eu-north-1.amazonaws.com/${aws_cognito_user_pool.user_pool.id}"
    audience = [aws_cognito_user_pool_client.user_pool_client.id]
  }
}




# Creating API Gateway
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
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.cognito_auth.id
}
# Allow API Gateway to invoke Lambda
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}
