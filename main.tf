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

module "glue" {
  source = "./modules/glue"
  # Aquí puedes pasar variables necesarias, por ejemplo:
  # glue_database_name = var.glue_database_name
}
