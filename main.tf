provider "aws" {
    region= "us-east-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "myapp-vpc"
  cidr = var.vpc_cidr_block

  azs             = [var.availability-zones]
  public_subnets  = [var.subnet_cidr_block]

  enable_nat_gateway = true
  enable_vpn_gateway = true
  public_subnet_tags = {
     Name = "${var.env_prefix}-subnet-1"
  }
  tags = {
    Terraform = "true"
    Name = "${var.env_prefix}-vpc"
  }
}

module "myapp_server" {
  source = "./modules/webserver"
  vpc_id = module.vpc.vpc_id
  availability-zones = var.availability-zones
  env_prefix = var.env_prefix
  my_ip = var.my_ip
  img_name = var.img_name
  subnet_id = module.vpc.public_subnets[0]
  instance_type = var.instance_type
}