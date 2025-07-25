output "athena_query_results_bucket" {
  value = aws_s3_bucket.athena_query_results.bucket
}

output "glue_assets_bucket" {
  value = aws_s3_bucket.glue_assets.bucket
}

output "curated_sensordata_bucket" {
  value = aws_s3_bucket.curated_sensordata.bucket
}

output "raw_sensordata_bucket" {
  value = aws_s3_bucket.raw_sensordata.bucket
}
