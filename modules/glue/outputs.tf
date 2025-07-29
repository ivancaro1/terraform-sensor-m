output "glue_job_names" {
  description = "Nombres de los Glue Jobs creados"
  value = [for job in aws_glue_job.this : job.name]
}

output "glue_job_arns" {
  description = "ARNs de los Glue Jobs creados"
  value = [for job in aws_glue_job.this : job.arn]
}

output "glue_jobs_map" {
  description = "Mapa de Glue Jobs con nombre como key y ARN como value"
  value = {
    for job in aws_glue_job.this :
    job.name => job.arn
  }
}