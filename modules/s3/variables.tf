variable "athena_query_results_bucket" {
  description = "Nombre del bucket para resultados de consultas de Athena."
  type        = string
}

variable "glue_assets_bucket" {
  description = "Nombre del bucket para assets de Glue."
  type        = string
}

variable "curated_sensordata_bucket" {
  description = "Nombre del bucket para datos curados de sensores."
  type        = string
}

variable "raw_sensordata_bucket" {
  description = "Nombre del bucket para datos crudos de sensores."
  type        = string
}

variable "tags" {
  description = "Etiquetas a aplicar a los buckets."
  type        = map(string)
  default     = {}
}
