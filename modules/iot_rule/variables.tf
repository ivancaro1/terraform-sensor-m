variable "rule_name" {
  description = "Nombre de la regla de IoT"
  type        = string
}

variable "sql" {
  description = "SQL statement para la regla"
  type        = string
}

variable "sql_version" {
  description = "Versión del SQL de IoT"
  type        = string
  default     = "2016-03-23"
}

variable "s3_bucket_name" {
  description = "Nombre del bucket S3 de destino"
  type        = string
}

variable "s3_key" {
  description = "Key de S3 para almacenar los datos"
  type        = string
}

variable "s3_canned_acl" {
  description = "Canned ACL para el objeto S3"
  type        = string
  default     = "private"
}

variable "role_arn" {
  description = "ARN del role de IAM para la acción de S3"
  type        = string
}
