resource "aws_iot_topic_rule" "this" {
  name        = var.rule_name
  enabled     = true
  sql         = var.sql
  sql_version = var.sql_version

  s3 {
    bucket_name = var.s3_bucket_name
    key         = var.s3_key
    role_arn    = var.role_arn
    canned_acl  = var.s3_canned_acl
  }
}
