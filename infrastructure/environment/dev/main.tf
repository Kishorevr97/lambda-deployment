module "iam" {
  source = "../../modules/iam"
  
}


module "ecr" {
  source    = "../../modules/ecr"

 
}



module "lambda" {
  source = "../../modules/lambda"
  lambda_role_arn = module.iam.lambda_role_arn
  attach_basic_execution = module.iam.attach_basic_execution
}
