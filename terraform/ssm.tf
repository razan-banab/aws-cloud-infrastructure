resource "aws_ssm_parameter" "db_password" {
  name             = "/cloud-project/database/password"
  type             = "SecureString"
  value_wo         = var.db_password
  value_wo_version = 1
}