# GCreate new VPC for infra
resource "aws_vpc" "vpc0" {
  cidr_block = "10.6.0.0/16"

  tags = {
    Name = "vpc0"
  }
}

# Create IGW for access to internet
resource "aws_internet_gateway" "igw0" {
  vpc_id = aws_vpc.vpc0.id
  tags = {
    Name = "igw0"
  }
}

# Allow internet connection
resource "aws_route" "internet_access" {
  gateway_id     = aws_internet_gateway.igw0.id
  route_table_id = aws_vpc.vpc0.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"

  # Wait for VPC and IGW
  depends_on = [
    aws_internet_gateway.igw0,
    aws_vpc.vpc0
  ]
}

# Create a subnet for VM
resource "aws_subnet" "sub0" {
  vpc_id            = aws_vpc.vpc0.id
  cidr_block        = "10.6.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "sub0"
  }
}

# Create security group to allow SSH from anywhere
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH connection from anywhere"
  vpc_id      = aws_vpc.vpc0.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "Allow SSH"
  }
}