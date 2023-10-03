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

module "network" {
  source = "./modules/network_setup"
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
  subnet_id                   = module.network.subnet_id
  private_ip                  = "10.6.1.10"
  associate_public_ip_address = true
  vpc_security_group_ids      = [module.network.security_group]

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
  user_data = file("./bootstrap.yaml")
}

# Add security groups
# Add public IP to connect
# make it so that it's configured
# Random password for user
# kubectl and awscli installed
