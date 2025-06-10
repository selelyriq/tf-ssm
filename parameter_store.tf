resource "aws_ssm_parameter" "cloudwatch_config" {
  name  = "cloudwatch_config"
  type  = "String"
  value = file("${path.module}/scripts/cloudwatch_config.json")
}