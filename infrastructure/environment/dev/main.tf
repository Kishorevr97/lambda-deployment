module "iam" {
  source = "../../Modules/IAM"
  
}

module "ecr" {
  source    = "../../Modules/ECR"
}



module "lamda" {
  source = "../../Modules/LAMDA"
  lambda_role_arn = module.iam.lambda_role_arn
  attach_basic_execution = module.iam.attach_basic_execution
  lambda_services = var.lambda_services
}
