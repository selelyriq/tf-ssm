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

### Instance-Based Targeting (Traditional)

```hcl
module "ssm_automation" {
  source = "./path/to/this/module"
  
  # Instance targeting
  target_type = "instance"
  instance_id = aws_instance.example.id
  efs_id      = aws_efs_file_system.example.id
  
  scripts = {
    ping_google = "scripts/ping_google.sh"
    hello_world = "scripts/hello_world.sh"
    custom_app_setup = "scripts/setup_app.sh"
  }
}
```

### Tag-Based Targeting (Auto Scaling Groups)

```hcl
module "ssm_automation" {
  source = "./path/to/this/module"
  
  # Tag targeting - perfect for ASGs
  target_type   = "tag"
  target_key    = "AutoScalingGroup"
  target_values = ["my-asg-name"]
  efs_id        = aws_efs_file_system.example.id
  
  scripts = {
    health_check = "scripts/asg_health_check.sh"
    scale_prep   = "scripts/prepare_for_scaling.sh"
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
- `efs_id` (string): The ID of the EFS filesystem to mount
- `scripts` (map(string)): Map of script names to file paths (provided by root module)

### Targeting Options
- `target_type` (string): Either "instance" or "tag" (default: "instance")

**For Instance Targeting:**
- `instance_id` (string): The ID of the instance to run commands on

**For Tag Targeting:**
- `target_key` (string): The tag key (e.g., "AutoScalingGroup")
- `target_values` (list(string)): List of tag values to target

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
