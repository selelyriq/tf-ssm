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

output "efs_mount_target_dns_name" {
  description = "DNS name of the EFS mount target"
  value       = aws_efs_mount_target.informatica_cluster.dns_name
}

output "efs_access_point_id" {
  description = "ID of the EFS access point"
  value       = aws_efs_access_point.informatica_cluster.id
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for SSM logs"
  value       = aws_s3_bucket.ssm_logs.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for SSM logs"
  value       = aws_s3_bucket.ssm_logs.arn
}

output "cloudwatch_association_id" {
  description = "ID of the CloudWatch SSM association"
  value       = aws_ssm_association.cloudwatch_config.association_id
}

output "efs_mount_association_id" {
  description = "ID of the EFS mount SSM association"
  value       = aws_ssm_association.efs_mount.association_id
} 