# Example Root Module Usage
# This demonstrates how engineers would use the SSM automation module with AutoScaling Groups

# Example EFS filesystem (you would have your own)
resource "aws_efs_file_system" "example" {
  creation_token = "example-efs"

  tags = {
    Name = "Example EFS"
  }
}

# Example Launch Template
resource "aws_launch_template" "example" {
  name_prefix   = "example-"
  image_id      = "ami-0abcdef1234567890" # Replace with actual AMI
  instance_type = "t3.micro"

  # Use the user_data script output from the SSM module
  user_data = base64encode(module.ssm_automation.user_data_script)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name             = "Example ASG Instance"
      AutoScalingGroup = "example-asg"
    }
  }
}

# Example AutoScaling Group
resource "aws_autoscaling_group" "example" {
  name                = "example-asg"
  vpc_zone_identifier = ["subnet-12345678", "subnet-87654321"] # Replace with actual subnet IDs
  min_size            = 1
  max_size            = 3
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Example ASG"
    propagate_at_launch = false
  }

  tag {
    key                 = "AutoScalingGroup"
    value               = "example-asg"
    propagate_at_launch = true
  }
}

# Use the SSM automation module
module "ssm_automation" {
  source = "../" # Path to the SSM module

  target_key    = "AutoScalingGroup"
  target_values = ["example-asg"]
  efs_id        = aws_efs_file_system.example.id

  # Custom scripts provided by the engineer
  scripts = {
    ping_google  = "scripts/ping_google.sh"
    hello_world  = "scripts/hello_world.sh"
    setup_my_app = "scripts/setup_application.sh"
  }
}

# Outputs
output "ssm_document_names" {
  description = "Names of created SSM documents"
  value       = module.ssm_automation.script_document_names
}

output "autoscaling_group_name" {
  description = "Name of the AutoScaling Group"
  value       = aws_autoscaling_group.example.name
} 