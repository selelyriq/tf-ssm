output "user_data_script" {
  description = "User data script template for EC2 instances"
  value = templatefile("${path.module}/scripts/user_data.sh", {
    efs_id = var.efs_id
    region = data.aws_region.current.name
  })
}

output "cloudwatch_config_document_name" {
  description = "Name of the CloudWatch configuration SSM document"
  value       = aws_ssm_document.cloudwatch_config.name
}

output "script_document_names" {
  description = "Names of the script SSM documents"
  value       = { for k, v in aws_ssm_document.script_documents : k => v.name }
}

output "ec2_profile_name" {
  description = "Name of the EC2 profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}

# Data source to get current region
data "aws_region" "current" {} 