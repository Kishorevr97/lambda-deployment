/*output "patient_service_repo_uri" {
  value = aws_ecr_repository.patient_service.repository_url
}

output "appointment_service_repo_uri" {
  value = aws_ecr_repository.appointment_service.repository_url
}*/

output "ecr_repository_url" {
value = aws_ecr_repository.sso_repo.repository_url
}
