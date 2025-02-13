resource "aws_ecr_repository" "sso_repo" {
  name = var.repo_name
}
