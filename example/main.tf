# Example Root Module Usage
# This demonstrates how engineers would use the SSM automation module

# Example EC2 instance (you would have your own)
resource "aws_instance" "example" {
  ami           = "ami-0abcdef1234567890" # Replace with actual AMI
  instance_type = "t3.micro"

  # Use the user_data script output from the SSM module
  user_data = module.ssm_automation.user_data_script

  tags = {
    Name = "Example Instance"
  }
}

# Example EFS filesystem (you would have your own)
resource "aws_efs_file_system" "example" {
  creation_token = "example-efs"

  tags = {
    Name = "Example EFS"
  }
}

# Use the SSM automation module
module "ssm_automation" {
  source = "../" # Path to the SSM module

  instance_id = aws_instance.example.id
  efs_id      = aws_efs_file_system.example.id

  # Custom scripts provided by the engineer
  scripts = {
    ping_google     = "scripts/ping_google.sh"
    hello_world     = "scripts/hello_world.sh"
    setup_my_app    = "scripts/setup_application.sh"
  }
}

# Outputs
output "ssm_document_names" {
  description = "Names of created SSM documents"
  value       = module.ssm_automation.script_document_names
} 