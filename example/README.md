# SSM Automation Module - Example Usage

This example demonstrates how to use the SSM automation module with custom scripts.

## Structure

```
example/
├── main.tf                    # Root module configuration
├── scripts/                   # Your custom scripts directory
│   ├── ping_google.sh        # Network connectivity test
│   ├── hello_world.sh        # Basic system info script
│   └── setup_application.sh  # Application setup script
└── README.md                 # This file
```

## How It Works

1. **Create Your Scripts**: Place your custom scripts in the `scripts/` directory
2. **Configure Module**: In `main.tf`, choose your targeting strategy and reference your scripts
3. **Deploy**: Run `terraform apply` to deploy the infrastructure
4. **Execution**: The SSM module will:
   - Create SSM documents for each script
   - Deploy the EFS mount user data script to instances
   - Configure CloudWatch monitoring
   - Execute scripts on target instances (by instance ID or tag)

## Workflow Examples

### Instance Targeting
```bash
# 1. Add your custom scripts to the scripts directory
echo '#!/bin/bash\necho "My custom script"' > scripts/my_script.sh

# 2. Configure for instance targeting in main.tf
# module "ssm_automation" {
#   target_type = "instance"
#   instance_id = aws_instance.example.id
#   scripts = {
#     my_script = "scripts/my_script.sh"
#   }
# }

# 3. Deploy
terraform init && terraform apply
```

### Tag Targeting (ASG)
```bash
# 1. Add your ASG-specific scripts
echo '#!/bin/bash\necho "ASG health check"' > scripts/health_check.sh

# 2. Configure for tag targeting in main.tf
# module "ssm_automation" {
#   target_type   = "tag"
#   target_key    = "AutoScalingGroup"
#   target_values = ["my-asg"]
#   scripts = {
#     health_check = "scripts/health_check.sh"
#   }
# }

# 3. Deploy
terraform init && terraform apply
```

## Built-in Features

- **EFS Mount**: Automatically mounts EFS filesystem to `/opt/informatica_cluster`
- **CloudWatch**: Configures CloudWatch Agent for monitoring
- **Flexible Scripts**: Add any number of custom scripts
- **SSM Integration**: All scripts run via AWS Systems Manager

## Script Requirements

- Scripts must be executable bash scripts
- Use absolute paths for file operations
- Consider that scripts run with root privileges via SSM
- EFS mount point: `/opt/informatica_cluster` 