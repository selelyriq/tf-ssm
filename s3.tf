# S3 bucket for SSM command logs
resource "aws_s3_bucket" "ssm_logs" {
  bucket = "informatica-cluster-ssm-logs"
}

# IAM policy for SSM to write to S3 bucket
resource "aws_iam_role_policy" "ssm_s3_logs" {
  name = "ssm-s3-logs-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.ssm_logs.arn,
          "${aws_s3_bucket.ssm_logs.arn}/*"
        ]
      }
    ]
  })
}

# S3 bucket policy to allow SSM service access
resource "aws_s3_bucket_policy" "ssm_logs" {
  bucket = aws_s3_bucket.ssm_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSSMAccess"
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.ssm_logs.arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "AllowSSMListBucket"
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.ssm_logs.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}