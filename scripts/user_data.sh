#! /bin/bash

# Create the mount point
sudo mkdir -p /opt/informatica_cluster

# Update the system
sudo yum update -y
sudo yum install -y amazon-efs-utils

for i in {1..12}; do
  if getent hosts "${efs_id}.efs.${region}.amazonaws.com" >/dev/null; then
    echo "[$(date -Is)] EFS DNS resolved"
    break
  fi
  echo "[$(date -Is)] Waiting for EFS DNS… (attempt $i/12)"
  sleep 5
done

# Mount the EFS filesystem
sudo mount -t efs -o tls ${efs_id}:/ /opt/informatica_cluster
df -h > /tmp/df_output.txt
sudo chmod 777 /tmp/df_output.txt
sudo cat /tmp/df_output.txt

# Verify mount and set permissions
if mountpoint -q /opt/informatica_cluster; then
    chown 1000:1000 /opt/informatica_cluster
    chmod 755 /opt/informatica_cluster
    echo "EFS filesystem mounted and configured successfully"
else
    echo "Failed to mount EFS filesystem"
    exit 1
fi

