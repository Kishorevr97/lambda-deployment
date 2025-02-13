variable "repo_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "my-sso-repo"
}

variable "ecr_repository_url" {
  description = "ECR repository url"
  type        = string
}

