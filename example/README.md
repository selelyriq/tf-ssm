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
2. **Configure Module**: In `main.tf`, reference your scripts via the `scripts` variable
3. **Deploy**: Run `terraform apply` to deploy the infrastructure
4. **Execution**: The SSM module will:
   - Create SSM documents for each script
   - Deploy the EFS mount user data script to instances
   - Configure CloudWatch monitoring
   - Execute scripts on target instances

## Workflow Example

```bash
# 1. Add your custom scripts to the scripts directory
echo '#!/bin/bash\necho "My custom script"' > scripts/my_script.sh

# 2. Update main.tf to include your script
# scripts = {
#   my_script = "scripts/my_script.sh"
# }

# 3. Deploy
terraform init
terraform plan
terraform apply
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