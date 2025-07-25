resource "aws_s3_bucket" "athena_query_results" {
  bucket = var.athena_query_results_bucket
  #tags   = var.tags
}

resource "aws_s3_bucket" "glue_assets" {
  bucket = var.glue_assets_bucket
  #tags   = var.tags
}

resource "aws_s3_bucket" "curated_sensordata" {
  bucket = var.curated_sensordata_bucket
  #tags   = var.tags
}

resource "aws_s3_bucket" "raw_sensordata" {
  bucket = var.raw_sensordata_bucket
  #tags   = var.tags
}
