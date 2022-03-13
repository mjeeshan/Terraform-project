provider "aws" {
    region= "us-east-1"

}

variable "subnet-cidr-block"{
    description= "CIDR block for aws"
    default = "10.0.30.0/16"
    type = string
}
resource "aws_vpc" "development-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
      Name = "developer-vpc-tag"
  }
}

resource "aws_subnet" "development-subnet-1" {
  vpc_id     = aws_vpc.development-vpc.id
  cidr_block = var.subnet-cidr-block
  availability_zone= "us-east-1a"

  tags = {
    Name = "development-subnet-1-tag"
  }
}

output "development-vpc-id" {
    value = aws_vpc.development-vpc.id
}


output "development-subnet-1-id" {
    value = aws_subnet.development-subnet-1.id
}
