#!/bin/bash

# Example script: Application setup
echo "Starting application setup..."

# Create application directories
sudo mkdir -p /opt/myapp/{bin,logs,config}
sudo chown ec2-user:ec2-user /opt/myapp -R

# Install required packages
sudo yum update -y
sudo yum install -y htop curl wget

# Download and setup application (example)
echo "Application setup completed successfully"
echo "Setup timestamp: $(date)" > /opt/myapp/logs/setup.log

# Verify EFS mount is available
if mountpoint -q /opt/informatica_cluster; then
    echo "EFS mount verified: /opt/informatica_cluster is mounted"
    ls -la /opt/informatica_cluster > /opt/myapp/logs/efs_contents.log
else
    echo "WARNING: EFS mount not found at /opt/informatica_cluster"
fi 