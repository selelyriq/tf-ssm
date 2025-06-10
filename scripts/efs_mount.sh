#!/bin/bash

exec > /tmp/ssm-debug.log 2>&1
set -e

# Get EFS filesystem ID from parameter (will be passed by Terraform)
EFS_ID="${1:-}"
if [ -z "$EFS_ID" ]; then
    echo "Error: EFS filesystem ID not provided"
    exit 1
fi

# Get current region
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)

# Install required packages
yum update -y
yum install -y nfs-utils amazon-efs-utils

# Create mount directory
mkdir -p /opt/informatica_cluster

# Add EFS to fstab using EFS utils (more reliable than plain NFS)
echo "${EFS_ID}.efs.${REGION}.amazonaws.com:/ /opt/informatica_cluster efs defaults,_netdev" >> /etc/fstab

# Retry logic to mount EFS
retryCnt=15
waitTime=30
while true; do
    mount -a 
    if mountpoint -q /opt/informatica_cluster || [ $retryCnt -lt 1 ]; then
        echo "File system mounted successfully"
        break
    fi
    echo "File system not available, retrying to mount..."
    ((retryCnt--))
    sleep $waitTime
done

# Verify mount and set permissions
if mountpoint -q /opt/informatica_cluster; then
    chown 1000:1000 /opt/informatica_cluster
    chmod 755 /opt/informatica_cluster
    echo "EFS filesystem mounted and configured successfully"
else
    echo "Failed to mount EFS filesystem"
    exit 1
fi
