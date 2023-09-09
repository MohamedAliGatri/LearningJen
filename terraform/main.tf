/*terraform {
  backend "s3" {
    bucket  = "caustaza-bucket"
    key     = "terraform.tfstate"
    region  = "eu-west-3"
    encrypt = true
  }
}*/

provider "aws" {
  region = "eu-west-3"
}

resource "aws_vpc" "caustaza_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}-vpc"
  }
}

/*resource "aws_s3_bucket" "caustaza-bucket" {
  bucket = "caustaza-bucket"
  acl    = "private"
  tags = {
    Name = "PrivateBucket"
  }
}*/

module "subnets" {
  source            = "./modules/subnets"
  vpc_id            = aws_vpc.caustaza_vpc.id
  avail_zone        = var.avail_zone
  pub_sub_1a        = var.pub_sub_1a
  env_prefix        = var.env_prefix
}
module "bastion" {
  source        = "./modules/jumpserver"
  vpc_id        = aws_vpc.caustaza_vpc.id
  subnet_id     = module.subnets.pub_sub_1a.id
  env_prefix    = var.env_prefix
  my_ip         = var.my_ip
  instance_type = var.instance_type
  pub_key_path  = var.pub_key_path
}
/*
module "caustaza-ecs" {
  source            = "./modules/ecs"
  vpc_id            = aws_vpc.caustaza_vpc.id
  jumpserver_sc     = module.bastion.bastion_sc
  env_prefix        = var.env_prefix
  ecs_instance_type = var.ecs_instance_type
  pub_key_path      = var.pub_key_path
  my_ip             = var.my_ip
  subnet_ids        = [module.subnets.priv_sub_3a.id, module.subnets.priv_sub_4b.id]
}*/



