resource "aws_s3_bucket" "athena_query_results" {
  bucket = var.athena_query_results_bucket
}

resource "aws_s3_bucket" "glue_assets" {
  bucket = var.glue_assets_bucket
}

resource "aws_s3_bucket" "curated_sensordata" {
  bucket = var.curated_sensordata_bucket
}

resource "aws_s3_bucket" "raw_sensordata" {
  bucket = var.raw_sensordata_bucket
}

resource "aws_s3_bucket_lifecycle_configuration" "raw_sensordata_lifecycle" {
  bucket = aws_s3_bucket.raw_sensordata.id

  rule {
    id     = "s3-archivo-rule"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = 10
      storage_class = "GLACIER_IR"
    }
  }
}
