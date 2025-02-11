terraform {
  backend "s3" {
    bucket         = "kishu-bucket-1"  
    key            = "lambda/development/terraform.tfstate"
    region         = "eu-north-1"            
    encrypt        = true
  }
}
