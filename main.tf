provider "aws" {
    region= "us-east-1"
}

variable vpc_cidr_block{
    description= "CIDR block for aws vpc"
}

variable subnet_cidr_block{
    description= "CIDR block for aws subnet"
}

variable availability-zones{
    description= "Availability zones for aws subnets"
}

variable env_prefix{
    description= "env zones to deploy"
}

variable my_ip {
    description= "IP's tp access EC2's"
}

variable instance_type {
        description= "instance type of EC2"

}

variable public_key_location{

}
resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
      Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id     = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone= var.availability-zones
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}



resource "aws_default_route_table" "main-route-table" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }


  tags = {
    Name = "${var.env_prefix}-route-table"
  }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id

  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_default_security_group" "default-sg" {
  vpc_id      = aws_vpc.myapp-vpc.id

  ingress {
    description      = "For SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip]
  }

  ingress {
    description      = "For outside access"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    prefix_list_ids  = []
  }

  tags = {
    Name = "${var.env_prefix}-default-sg"
  }
}


data  "aws_ami" "lastest-amazon-linux" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

   filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }


  }



resource "aws_instance" "myapp-server" {
  ami           = data.aws_ami.lastest-amazon-linux.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  subnet_id   = aws_subnet.myapp-subnet-1.id
  availability_zone= var.availability-zones
  associate_public_ip_address=true
  key_name = "terraform-aws"
  user_data = <<EOF
                    #!/bin/bash
                    sudo yum update -y && sudo yum install -y docker
                    sudo systemctl start docker
                    sudo usermod -aG docker ec2-user
                    docker run -p 8080:8080 nginx
                EOF

  tags = {
    Name = "${var.env_prefix}-server"
  }
}



output "aws_ami_id" {
    value = data.aws_ami.lastest-amazon-linux.id
}

output "ec2_public_ip" {
    value = aws_instance.myapp-server.public_ip
}