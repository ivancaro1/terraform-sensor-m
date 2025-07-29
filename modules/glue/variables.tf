variable "glue_jobs" {
  description = "Mapa de jobs de Glue a crear, cada uno con sus parámetros."
  type = map(object({
    name                     = string
    role_arn                 = string
    command_name             = string
    command_script_location  = string
    max_retries              = number
    timeout                  = number
    worker_type              = string
    number_of_workers        = number
    glue_version             = string
    python_version           = string
    tags                     = map(string)
    default_arguments        = map(string)
  }))
  default = {}
}

variable "default_tags" {
  description = "Tags por defecto para todos los jobs de Glue."
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Ambiente actual (ej: dev, prod)"
  type        = string
}

variable "aws_region" {
  description = "Región de AWS"
  type        = string
}

variable "glue_assets_bucket" {
  description = "Bucket para scripts y logs de Glue"
  type        = string
}

variable "raw_sensordata_bucket" {
  description = "Bucket de datos sin procesar"
  type        = string
}

variable "curated_sensordata_bucket" {
  description = "Bucket de datos procesados"
  type        = string
}