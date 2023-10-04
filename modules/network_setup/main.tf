# GCreate new VPC for infra
resource "aws_vpc" "vpc0" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

# Create IGW for access to internet
resource "aws_internet_gateway" "igw0" {
  vpc_id = aws_vpc.vpc0.id
  tags = {
    Name = var.igw_name
  }
}

# Allow internet connection
resource "aws_route" "internet_access" {
  gateway_id             = aws_internet_gateway.igw0.id
  route_table_id         = aws_vpc.vpc0.default_route_table_id
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
  cidr_block        = var.subnet_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = var.subnet_name
  }
}

# Create security group to allow SSH from anywhere
# And connection to anywhere
resource "aws_security_group" "allowed_ports" {
  name        = "allowed ports"
  description = "Allowed port and egress all"
  vpc_id      = aws_vpc.vpc0.id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}