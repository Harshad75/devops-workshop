provider "aws" {
  region = "us-west-1"
}

resource "aws_instance" "demo-instance" {
  ami           = "ami-06e4ca05d431835e9"
  key_name      = "demo-instance"
  instance_type = "t2.micro"
  security_groups =  [ "demo-terraform-sg-sg-sg" ]
}

resource "aws_security_group" "demo-terraform-sg-sg" {
  name        = "demo-terraform-sg-sg-sg"
  description = "Allow SSH access"

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Manifest SG"
  }
}