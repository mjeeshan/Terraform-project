resource "aws_security_group" "default-sg" {
  vpc_id      = var.vpc_id
  name = "default-sg"
  ingress {
    description      = "For SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip]
  }

  ingress {
    description      = "For Director service"
    from_port        = 1234
    to_port          = 1234
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "For API Service"
    from_port        = 4000
    to_port          = 4000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "For Dashboard Service"
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
    values = [var.img_name]
  }

   filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "myapp-server" {
  ami           = data.aws_ami.lastest-amazon-linux.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.default-sg.id]
  subnet_id   = var.subnet_id
  availability_zone= var.availability-zones
  associate_public_ip_address=true
  key_name = "terraform-aws"
  user_data = file("entrypoint.sh")

  tags = {
    Name = "${var.env_prefix}-server"
  }
}

