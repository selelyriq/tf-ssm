# SSM Automation Module

This module provides flexible SSM automation capabilities for EC2 instances.

## Features

- **Dynamic Script Execution**: Accepts scripts from root module for maximum flexibility
- **EFS Mount Automation**: Automatically mounts EFS filesystem to instances
- **CloudWatch Agent**: Configures CloudWatch monitoring
- **SSM Document Management**: Creates and manages SSM documents for each script

## Usage

### Basic Usage

```hcl
module "ssm_automation" {
  source = "./path/to/this/module"
  
  instance_id = aws_instance.example.id
  efs_id      = aws_efs_file_system.example.id
  
  scripts = {
    ping_google = "scripts/ping_google.sh"
    hello_world = "scripts/hello_world.sh"
    custom_app_setup = "scripts/setup_app.sh"
  }
}
```

### Workflow

1. **Create Scripts**: Engineers create their scripts in the root module's `scripts/` directory
2. **Define Scripts**: Pass script paths via the `scripts` variable
3. **Module Execution**: Module reads scripts at runtime and creates SSM documents
4. **Deployment**: SSM documents are deployed to target instances
5. **EFS Mount**: EFS filesystem is automatically mounted to all instances

## Variables

- `instance_id` (string): The ID of the instance to run commands on
- `efs_id` (string): The ID of the EFS filesystem to mount
- `scripts` (map(string)): Map of script names to file paths (provided by root module)

## Built-in Features

The module includes essential built-in functionality:
- **EFS Mount Script**: Automatically mounts EFS filesystem to `/opt/informatica_cluster` via user_data
- **CloudWatch Config**: Configures CloudWatch Agent on instances via inline SSM document
- **Dynamic Script Execution**: Creates SSM documents for any scripts provided by the root module

## Directory Structure

```
ssm-module/
├── run_command.tf           # Main SSM document and association resources
├── variables.tf             # Module variables (scripts input)
├── outputs.tf              # Module outputs (user_data script, document names)
├── iam.tf                  # IAM roles and policies
├── parameter_store.tf      # Parameter store configuration
└── scripts/                # Built-in module scripts
    ├── user_data.sh        # EFS mount script (output as user_data)
    └── cloudwatch_config.json # CloudWatch configuration
```
