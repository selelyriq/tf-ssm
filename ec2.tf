# Create a new EC2 instance
resource "aws_instance" "informatica_cluster" {
  ami                    = "ami-0fa810ae39b368d14"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.informatica_cluster.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = (templatefile("${path.module}/scripts/user_data.sh", {
    efs_id = aws_efs_file_system.informatica_cluster.id
    region = "us-east-1"
  }))

  tags = {
    Name = "informatica-cluster"
  }

  depends_on = [
    aws_efs_mount_target.informatica_cluster
  ]
}

# IAM role for EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "informatica-cluster-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "informatica-cluster-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# Attach AWS managed policies for SSM and CloudWatch
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_server_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Additional policy for accessing the specific parameter
resource "aws_iam_role_policy" "cloudwatch_config_access" {
  name = "cloudwatch-config-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = ["*"]
      }
    ]
  })
}

# EFS access policy
resource "aws_iam_role_policy" "efs_access" {
  name = "efs-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:DescribeMountTargets",
          "elasticfilesystem:DescribeAccessPoints",
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudwatch_logs_write_access" {
  name = "cloudwatch-logs-write-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}