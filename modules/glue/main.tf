resource "aws_glue_job" "this" {
  for_each = {
    for job in var.glue_jobs : "${job.name}-${var.environment}-${var.aws_region}" => job
  }

  name               = each.key
  role_arn           = each.value.role_arn
  max_retries        = lookup(each.value, "max_retries", 0)
  timeout            = lookup(each.value, "timeout", 480)
  worker_type        = lookup(each.value, "worker_type", "G.1X")
  number_of_workers  = lookup(each.value, "number_of_workers", 2)
  glue_version       = lookup(each.value, "glue_version", "5.0")
  execution_class    = "STANDARD"

  command {
    name            = lookup(each.value, "command_name", "glueetl")
    script_location = each.value.command_script_location
    python_version  = lookup(each.value, "python_version", "3")
  }

  execution_property {
    max_concurrent_runs = 1
  }

  default_arguments = merge(
    {
      "--enable-metrics"                = "true"
      "--enable-spark-ui"              = "true"
      "--spark-event-logs-path"        = "s3://${var.glue_assets_bucket}/sparkHistoryLogs/"
      "--enable-job-insights"          = "true"
      "--enable-observability-metrics" = "true"
      "--enable-glue-datacatalog"      = "true"
      "--job-bookmark-option"          = "job-bookmark-disable"
      "--job-language"                 = "python"
      "--TempDir"                      = "s3://${var.glue_assets_bucket}/temporary/"
      "--RAW_BUCKET"                   = var.raw_sensordata_bucket
      "--CURATED_BUCKET"               = var.curated_sensordata_bucket
      "--input_bucket"                 = var.raw_sensordata_bucket
      "--processed_bucket"             = var.curated_sensordata_bucket
    },
    lookup(each.value, "default_arguments", {})
  )
}

resource "aws_glue_trigger" "scheduled" {
  for_each = {
    for job_key, job in var.glue_jobs :
    "${job_key}-${var.environment}-${var.aws_region}" => job
    if try(job.schedule != null && job.schedule != "", false)
  }

  name     = "${each.key}-trigger"
  type     = "SCHEDULED"
  schedule = each.value.schedule

  actions {
    job_name = each.key
  }

  start_on_creation = true
  enabled           = true
}