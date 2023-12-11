provider "aws" {
  region = "us-west-1"
}

resource "aws_instance" "demo-instance" {
  ami           = "ami-06e4ca05d431835e9"
  key_name      = "demo-instance"
  instance_type = "t2.micro"
}