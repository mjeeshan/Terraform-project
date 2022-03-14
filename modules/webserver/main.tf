resource "aws_default_security_group" "default-sg" {
  vpc_id      = var.vpc_id

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
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  subnet_id   = var.subnet_id
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

