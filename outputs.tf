# Output IP address
# Output a random password for user

# Display the IP for connection
output "patchwerk_public_ip" {
  value       = aws_instance.patchwerk_vm.public_ip
  sensitive   = false
  description = "Public IP of the VM"
  depends_on  = [aws_instance.patchwerk_vm]
}
