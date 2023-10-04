output "vpc_id" {
  value       = aws_vpc.vpc0.id
  description = "ID for the new VPC created"
}

output "subnet_id" {
  value       = aws_subnet.sub0.id
  description = "ID of the subnet created"
}

output "security_group" {
  value       = aws_security_group.allowed_ports.id
  description = "Allow SSH group id"
}
