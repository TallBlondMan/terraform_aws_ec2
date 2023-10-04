variable "vpc_name" {
  type        = string
  default     = "vpc0"
  description = "Name of VPC"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.6.0.0/16"
  description = "VPC CIDR, use one of private access pools"
}

variable "subnet_name" {
  type        = string
  default     = "sub0"
  description = "Name of the subnet to create"
}

variable "subnet_cidr" {
  type        = string
  default     = "10.6.1.0/24"
  description = "Must be a part of vpc cidr pool"
}
locals {
  is_subnet_valid = cidrsubnet(var.vpc_cidr, 8, 0) == var.subnet_cidr
}
output "subnet_is_valid" {
  value = local.is_subnet_valid
}

variable "subnet_zone" {
  type        = string
  default     = "us-east-1a"
  description = "Zone on which the subnet will be assigned"
}


variable "igw_name" {
  type        = string
  default     = "igw0"
  description = "Name of internet gateway"
}

variable "security_group_name" {
  type        = string
  default     = "Allowed Ports"
  description = "A name for security groups"
}


variable "ingress_rules" {
  type = map(any)
  default = {
    rule1 = {
      description = "Allow SSH",
      port        = 22,
      protocol    = "tcp",
      cidr_blocks = ["0.0.0.0/0"],
    }
    rule2 = {
      description = "Allow HTTP",
      port        = 80,
      protocol    = "tcp",
      cidr_blocks = ["0.0.0.0/0"], 
    }
  }
  description = "Ingress rules to apply to machine"
}
# TODO:
# make use of is subnet_is_valid