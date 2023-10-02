terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.19.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
# Get the Virtual Private Network created 
resource "aws_vpc" "vpc0" {
  cidr_block = "10.6.0.0/16"

  tags = {
    Name = "vpc0"
  }
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
# Get latest Amazaon Linux 2 image with hvm and ebs
data "aws_ami" "amzn-linux-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
# Combine it all into a VM
resource "aws_instance" "patchwerk_vm" {
  ami           = data.aws_ami.amzn-linux-ami.id
  instance_type = "t2.micro"

  # Define the network interface and public IP
  subnet_id                   = aws_subnet.sub0.id
  private_ip                  = "10.6.1.10"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  # Define volume size and type
  root_block_device {
    volume_size = "20"
    volume_type = "gp2"
  }

  # Tags - name
  tags = {
    Name = "PatchwerkVM"
  }

  # Postprovision settings to include
  user_data = file("./bootstrap")
}

# Add security groups
# Add public IP to connect
# make it so that it's configured
# Random password for user
# kubectl and awscli installed