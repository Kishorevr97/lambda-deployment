module "iam" {
  source = "../../modules/iam"
  
}


module "ecr" {
  source    = "../../modules/ecr"
  ecr_repository_url=aws_ecr_repository.sso_repo.repository_url
 
}



module "lambda" {
  source = "../../modules/lambda"
  lambda_role_arn = module.iam.lambda_role_arn
  attach_basic_execution = module.iam.attach_basic_execution
}
