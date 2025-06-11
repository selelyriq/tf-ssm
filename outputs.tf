output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.informatica_cluster.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.informatica_cluster.public_ip
}

output "efs_id" {
  description = "ID of the EFS filesystem"
  value       = aws_efs_file_system.informatica_cluster.id
}

output "efs_dns_name" {
  description = "DNS name of the EFS filesystem"
  value       = aws_efs_file_system.informatica_cluster.dns_name
}

# output "efs_mount_target_dns_name" {
#   description = "A map of EFS mount target DNS names, keyed by subnet ID"
#   value       = { for subnet_id, mt in aws_efs_mount_target.informatica_cluster : subnet_id => mt.mount_target_dns_name }
# }

output "efs_access_point_id" {
  description = "ID of the EFS access point"
  value       = aws_efs_access_point.informatica_cluster.id
}
