terraform {
  required_providers { aws = { source = "hashicorp/aws", version = "~> 4.0" } }
}
provider "aws" {
  region = "us-east-1"
}

module "network" {
  source              = "../../modules/network"
  env                 = "dev"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
}

module "storage" {
  source     = "../../modules/storage"
  env        = "dev"
  table_name = "url-shortener-dev"
}

module "compute" {
  source             = "../../modules/compute"
  env                = "dev"
  aws_region         = "us-east-1"
  image_url          = "123456789012.dkr.ecr.us-east-1.amazonaws.com/url-shortener:dev"
  api_key            = "dev-api-key"
  base_url           = "https://dev.example.com"
  table_name         = module.storage.table_name
  execution_role_arn = module.security.execution_role_arn
  task_role_arn      = module.security.task_role_arn
  vpc_id             = module.network.vpc_id
  public_subnets     = module.network.public_subnets
}

module "security" {
  source    = "../../modules/security"
  env       = "dev"
  table_arn = module.storage.url_map_arn
  alb_arn   = module.compute.alb_arn
}
