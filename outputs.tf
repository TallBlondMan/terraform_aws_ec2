# Display the IP for connection
output "patchwerk_public_ip" {
  value       = format("Connect via SSH= ssh msmet@%s", aws_instance.patchwerk_vm.public_ip)
  sensitive   = false
  description = "Public IP of the VM"
  depends_on  = [aws_instance.patchwerk_vm]
}

# TODO:
# - Output a random password for user
# - Output for private IP
# - DNS name 
