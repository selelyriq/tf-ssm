# Sleep
# Wait 4 minutes (how long it takes for instance to be ready)
resource "time_sleep" "wait_240_seconds" {
  depends_on = [aws_instance.informatica_cluster]

  create_duration = "240s"
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

resource "aws_ssm_association" "cloudwatch_config" {
  name = aws_ssm_document.cloudwatch_config.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.informatica_cluster.id]
  }

  depends_on = [
    aws_instance.informatica_cluster,
    time_sleep.wait_240_seconds
  ]
}

resource "aws_ssm_document" "script_documents" {
  for_each      = var.scripts
  name          = each.key
  document_type = "Command"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Run ${each.key} script"
    mainSteps = [
      {
        action = "aws:runShellScript"
        name   = each.key
        inputs = {
          runCommand = split("\n", trimspace(file(each.value)))
        }
      }
    ]
  })

  depends_on = [
    aws_iam_role_policy_attachment.ssm_managed_instance_core,
    aws_iam_role_policy_attachment.cloudwatch_agent_server_policy,
    aws_iam_role_policy.cloudwatch_config_access
  ]
}

resource "aws_ssm_association" "script_associations" {
  for_each = var.scripts
  name     = aws_ssm_document.script_documents[each.key].name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.informatica_cluster.id]
  }

  depends_on = [
    aws_instance.informatica_cluster,
    time_sleep.wait_240_seconds
  ]
}
