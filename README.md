# SSM Automation Module for AutoScaling Groups

This module provides flexible SSM automation capabilities for EC2 instances in AutoScaling Groups using tag-based targeting.

## Features

- **Dynamic Script Execution**: Accepts scripts from root module for maximum flexibility
- **EFS Mount Automation**: Automatically mounts EFS filesystem to instances
- **CloudWatch Agent**: Configures CloudWatch monitoring
- **SSM Document Management**: Creates and manages SSM documents for each script
- **AutoScaling Group Support**: Automatically targets all instances in matching ASGs
- **Dynamic Scaling**: New instances launched by ASG automatically receive scripts

## Usage

### Basic Usage with AutoScaling Groups

```hcl
module "ssm_automation" {
  source = "./path/to/this/module"
  
  # Tag targeting for AutoScaling Groups
  target_key    = "AutoScalingGroup"
  target_values = ["my-asg-name"]
  efs_id        = aws_efs_file_system.example.id
  
  scripts = {
    health_check    = "scripts/asg_health_check.sh"
    app_setup      = "scripts/setup_application.sh"
    monitoring     = "scripts/setup_monitoring.sh"
  }
}
```

### Multiple AutoScaling Groups

```hcl
module "ssm_automation" {
  source = "./path/to/this/module"
  
  # Target multiple ASGs with same scripts
  target_key    = "AutoScalingGroup"
  target_values = ["web-asg", "api-asg", "worker-asg"]
  efs_id        = aws_efs_file_system.example.id
  
  scripts = {
    common_setup   = "scripts/common_setup.sh"
    security_audit = "scripts/security_check.sh"
  }
}
```

### Custom Tag Targeting

```hcl
module "ssm_automation" {
  source = "./path/to/this/module"
  
  # Use custom tag keys
  target_key    = "Environment"
  target_values = ["production", "staging"]
  efs_id        = aws_efs_file_system.example.id
  
  scripts = {
    env_setup = "scripts/environment_setup.sh"
  }
}
```

### Workflow

1. **Create Scripts**: Engineers create their scripts in the root module's `scripts/` directory
2. **Configure ASG**: Set up your AutoScaling Group with proper tags
3. **Define Scripts**: Pass script paths via the `scripts` variable
4. **Module Execution**: Module reads scripts at runtime and creates SSM documents
5. **Deployment**: SSM documents are deployed to instances matching the target tags
6. **EFS Mount**: EFS filesystem is automatically mounted to all instances

## Variables

### Required
- `target_values` (list(string)): List of tag values to target
- `efs_id` (string): The ID of the EFS filesystem to mount

### Optional
- `target_key` (string): The tag key to use for targeting (default: "AutoScalingGroup")
- `scripts` (map(string)): Map of script names to file paths (default: {})

## AutoScaling Group Configuration

Ensure your AutoScaling Group instances are properly tagged:

```hcl
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
```

## Built-in Features

The module includes essential built-in functionality:
- **EFS Mount Script**: Automatically mounts EFS filesystem to `/opt/informatica_cluster` via user_data
- **CloudWatch Config**: Configures CloudWatch Agent on instances via inline SSM document
- **Dynamic Script Execution**: Creates SSM documents for any scripts provided by the root module

## Directory Structure

```
ssm-module/
├── run_command.tf           # Main SSM document and association resources
├── variables.tf             # Module variables (target_key, target_values, scripts)
├── outputs.tf              # Module outputs (user_data script, document names)
├── iam.tf                  # IAM roles and policies
├── parameter_store.tf      # Parameter store configuration
└── scripts/                # Built-in module scripts
    ├── user_data.sh        # EFS mount script (output as user_data)
    └── cloudwatch_config.json # CloudWatch configuration
```
# tf-ssm-asg
