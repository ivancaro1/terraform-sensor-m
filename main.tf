terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "aws" {
  region = var.aws_region
}

module "s3" {
  source = "./modules/s3"

  athena_query_results_bucket = "aws-athena-query-results-${var.aws_region}-${var.aws_account_id}"
  glue_assets_bucket         = "aws-glue-assets-${var.aws_account_id}-${var.aws_region}"
  curated_sensordata_bucket  = "${var.name_prefix}-${var.environment}-${var.aws_region}-curated-sensordata"
  raw_sensordata_bucket      = "${var.name_prefix}-${var.environment}-${var.aws_region}-raw-sensordata"
  tags = merge({
    Environment = var.environment
    Owner       = var.aws_account_id
    Project     = var.name_prefix
  }, var.extra_tags)
}

module "iot_rules" {
  source = "./modules/iot_rule"
  for_each = { for rule in var.iot_rules : rule.rule_name => rule }
  rule_name      = each.value.rule_name
  sql            = each.value.sql
  s3_bucket_name = each.value.s3_bucket_name
  s3_key         = each.value.s3_key
  s3_canned_acl  = lookup(each.value, "s3_canned_acl", "private")
  role_arn       = each.value.role_arn
  
  depends_on = [module.iam]
}

module "iot_device" {
  source     = "./modules/iot_device"
  for_each   = toset(var.iot_device_names)
  thing_name = each.value
  policy_document = <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Action": [
            "iot:Connect",
            "iot:Publish",
            "iot:Subscribe",
            "iot:Receive"
        ],
        "Resource": "*"
        }
    ]
    }
    EOF
    }

module "iam" {
  source = "./modules/iam"
  
  iam_roles = var.iam_roles
  
  default_tags = {
    Environment = var.environment
    Project     = var.name_prefix
    Owner       = var.aws_account_id
  }
}


module "glue" {
  source      = "./modules/glue"

  glue_jobs               = var.glue_jobs
  environment             = var.environment
  aws_region              = var.aws_region
  glue_assets_bucket      = module.s3.glue_assets_bucket
  curated_sensordata_bucket = module.s3.curated_sensordata_bucket
  raw_sensordata_bucket   = module.s3.raw_sensordata_bucket

  depends_on = [module.iam]
}