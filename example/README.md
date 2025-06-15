# SSM Automation Module - Example Usage

This example demonstrates how to use the SSM automation module with AutoScaling Groups using tag-based targeting.

## Structure

```
example/
├── main.tf                    # Root module configuration with ASG setup
├── scripts/                   # Your custom scripts directory
│   ├── ping_google.sh        # Network connectivity test
│   ├── hello_world.sh        # Basic system info script
│   └── setup_application.sh  # Application setup script
└── README.md                 # This file
```

## How It Works

1. **Create Your Scripts**: Place your custom scripts in the `scripts/` directory
2. **Configure AutoScaling Group**: Set up your ASG with proper tags for targeting
3. **Configure Module**: In `main.tf`, specify the tag key and values for targeting
4. **Deploy**: Run `terraform apply` to deploy the infrastructure
5. **Execution**: The SSM module will:
   - Create SSM documents for each script
   - Deploy the EFS mount user data script to ASG instances
   - Configure CloudWatch monitoring
   - Execute scripts on instances matching the specified tags

## AutoScaling Group Configuration

The module uses tag-based targeting to identify instances within your AutoScaling Groups:

```hcl
# Example AutoScaling Group with proper tagging
resource "aws_autoscaling_group" "example" {
  name                = "my-application-asg"
  vpc_zone_identifier = var.subnet_ids
  min_size            = 1
  max_size            = 5
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  # This tag will be used for SSM targeting
  tag {
    key                 = "AutoScalingGroup"
    value               = "my-application-asg"
    propagate_at_launch = true
  }
}

# Module configuration
module "ssm_automation" {
  source = "../"

  target_key    = "AutoScalingGroup"
  target_values = ["my-application-asg"]
  efs_id        = aws_efs_file_system.example.id

  scripts = {
    health_check    = "scripts/health_check.sh"
    setup_app      = "scripts/setup_application.sh"
  }
}
```

## Workflow Example

```bash
# 1. Add your custom scripts to the scripts directory
echo '#!/bin/bash\necho "ASG health check"' > scripts/health_check.sh
chmod +x scripts/health_check.sh

# 2. Configure your ASG and module in main.tf
# (See the main.tf file for complete example)

# 3. Deploy
terraform init && terraform apply

# 4. The module will automatically target all instances in your ASG
# that have the specified tag key/value pair
```

## Built-in Features

- **EFS Mount**: Automatically mounts EFS filesystem to `/opt/informatica_cluster`
- **CloudWatch**: Configures CloudWatch Agent for monitoring
- **Flexible Scripts**: Add any number of custom scripts
- **SSM Integration**: All scripts run via AWS Systems Manager
- **AutoScaling Group Support**: Automatically targets all instances in matching ASGs
- **Dynamic Scaling**: New instances launched by ASG will automatically receive scripts

## Script Requirements

- Scripts must be executable bash scripts
- Use absolute paths for file operations
- Consider that scripts run with root privileges via SSM
- EFS mount point: `/opt/informatica_cluster`
- Scripts will execute on all instances matching the target tags 