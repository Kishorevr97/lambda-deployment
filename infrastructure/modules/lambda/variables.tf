variable "region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "us-east-1"
}



variable "lambda_role_arn" {
}

variable "attach_basic_execution" {
}
