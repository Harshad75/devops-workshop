provider "aws" {
  region = "us-west-1"
}

resource "aws_instance" "demo-instance-1" {
  ami                    = "ami-0cbd40f694b804622"
  key_name               = "demo-instance"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.custom_vpc_subnet-public-01.id
  vpc_security_group_ids = [aws_security_group.demo-terraform.id]
  for_each               = toset(["jenkins-master", "build-slave", "ansible"])
  tags = {
    Name = "${each.key}"
  }
}

resource "aws_security_group" "demo-terraform" {
  vpc_id      = aws_vpc.custom_vpc.id
  name        = "demo-terraform-sg"
  description = "Allow SSH access"

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Manifest SG"
  }
}

resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.11.0.0/16"
  tags = {
    Name = "custom_vpc"
  }
}

resource "aws_subnet" "custom_vpc_subnet-public-01" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.11.10.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-west-1a"
  tags = {
    Name = "custom_vpc_subnet-public-01"
  }
}

resource "aws_subnet" "custom_vpc_subnet-public-02" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.11.11.0/24"
  availability_zone       = "us-west-1c"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "custom_vpc_subnet-public-02"
  }
}

resource "aws_internet_gateway" "custom_vpc-igw" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "custom_vpc-igw"
  }
}

resource "aws_route_table" "custom-vpc-rt" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom_vpc-igw.id
  }
}

resource "aws_route_table_association" "custom-vpc-rta-public-1" {
  subnet_id      = aws_subnet.custom_vpc_subnet-public-01.id
  route_table_id = aws_route_table.custom-vpc-rt.id
}

resource "aws_route_table_association" "custom-vpc-rta-public-2" {
  subnet_id      = aws_subnet.custom_vpc_subnet-public-02.id
  route_table_id = aws_route_table.custom-vpc-rt.id
}