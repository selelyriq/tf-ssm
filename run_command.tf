# Sleep
# Wait 1 minute
resource "time_sleep" "wait_60_seconds" {
  depends_on = [aws_instance.informatica_cluster]

  create_duration = "240s"
}

locals {
  efs_mount_script = file("${path.module}/scripts/efs_mount.sh")
}

resource "aws_ssm_document" "cloudwatch_config" {
  name            = "cloudwatch_config"
  document_type   = "Command"
  document_format = "YAML"
  content         = <<EOF
schemaVersion: '2.2'
description: Configure CloudWatch Agent
parameters: {}
mainSteps:
  - action: aws:configurePackage
    name: configurePackage
    inputs:
      name: AmazonCloudWatchAgent
      action: install
  - action: aws:runShellScript
    name: configureCloudWatchAgent
    inputs:
      runCommand:
        - echo "Starting CloudWatch Agent config fetch..."
        - sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:cloudwatch_config
        - echo "CloudWatch Agent fetch-config completed."
EOF

  depends_on = [
    aws_iam_role_policy_attachment.ssm_managed_instance_core,
    aws_iam_role_policy_attachment.cloudwatch_agent_server_policy,
    aws_iam_role_policy.cloudwatch_config_access
  ]
}

resource "aws_ssm_document" "efs_mount" {
  name            = "efs_mount"
  document_type   = "Command"
  document_format = "YAML"
  content         = <<EOF
schemaVersion: '2.2'
description: Mount EFS filesystem
parameters:
  EfsId:
    type: String
    description: EFS filesystem ID
    default: ""
mainSteps:
  - action: aws:runShellScript
    name: mount_efs
    inputs:
      runCommand:
        - |
          #!/bin/bash
          while ! systemctl is-active --quiet amazon-ssm-agent; do
            echo "Waiting for SSM Agent..."
            sleep 5
          done

          whoami > /tmp/whoami_ssm.txt
          id >> /tmp/whoami_ssm.txt

          exec > /tmp/ssm-debug.log 2>&1
          set -e

          EFS_ID="$${EfsId}"
          if [ -z "$EFS_ID" ]; then
              echo "Error: EFS filesystem ID not provided"
              exit 1
          fi

          REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
          yum update -y
          yum install -y nfs-utils amazon-efs-utils
          mkdir -p /opt/informatica_cluster
          echo "$${EFS_ID}.efs.$${REGION}.amazonaws.com:/ /opt/informatica_cluster efs defaults,_netdev" >> /etc/fstab

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

          if mountpoint -q /opt/informatica_cluster; then
              chown 1000:1000 /opt/informatica_cluster
              chmod 755 /opt/informatica_cluster
              echo "EFS filesystem mounted and configured successfully"
          else
              echo "Failed to mount EFS filesystem"
              exit 1
          fi
EOF

  depends_on = [
    aws_iam_role_policy_attachment.ssm_managed_instance_core,
    aws_iam_role_policy.efs_access
  ]
}

resource "aws_ssm_association" "cloudwatch_config" {
  name = aws_ssm_document.cloudwatch_config.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.informatica_cluster.id]
  }

  output_location {
    s3_bucket_name = "informatica-cluster-ssm-logs"
    s3_key_prefix  = "cloudwatch_config"
  }

  depends_on = [
    aws_ssm_document.cloudwatch_config,
    aws_ssm_parameter.cloudwatch_config,
    aws_instance.informatica_cluster,
    aws_iam_role_policy_attachment.ssm_managed_instance_core,
    aws_iam_role_policy_attachment.cloudwatch_agent_server_policy,
    aws_iam_role_policy.cloudwatch_config_access,
    aws_iam_role_policy.ssm_s3_logs,
    time_sleep.wait_60_seconds
  ]
}

resource "aws_ssm_association" "efs_mount" {
  name = aws_ssm_document.efs_mount.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.informatica_cluster.id]
  }

  parameters = {
    EfsId = aws_efs_file_system.informatica_cluster.id
  }

  output_location {
    s3_bucket_name = "informatica-cluster-ssm-logs"
    s3_key_prefix  = "efs_mount"
  }

  depends_on = [
    aws_ssm_document.efs_mount,
    aws_instance.informatica_cluster,
    aws_iam_role_policy_attachment.ssm_managed_instance_core,
    aws_iam_role_policy.efs_access,
    aws_iam_role_policy.ssm_s3_logs,
    time_sleep.wait_60_seconds
  ]
}