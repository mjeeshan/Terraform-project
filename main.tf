provider "aws" {
    region= "us-east-1"
}


resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
      Name = "${var.env_prefix}-vpc"
  }
}


module "myapp_subnet" {
  source = "./modules/subnet"
  subnet_cidr_block = var.subnet_cidr_block
  vpc_id = aws_vpc.myapp-vpc.id
  availability-zones = var.availability-zones
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  env_prefix = var.env_prefix
}

module "myapp_server" {
  source = "./modules/webserver"
  vpc_id = aws_vpc.myapp-vpc.id
  availability-zones = var.availability-zones
  env_prefix = var.env_prefix
  my_ip = var.my_ip
  img_name = var.img_name
  subnet_id = module.myapp_subnet.subnet-1.id
  instance_type = var.instance_type
}