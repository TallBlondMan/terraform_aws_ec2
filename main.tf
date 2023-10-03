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

# Initialize the network
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

# Get the cloud-init
data "template_file" "cloud_init" {
  template = file("./bootstrap.yaml")
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
  user_data = data.template_file.cloud_init.rendered
}


# Random password for user
# kubectl and awscli installed

# get the K8s cluster installed
# let the machine administer the cluster

# Variablize most of the thing
# Create a instance module for this file