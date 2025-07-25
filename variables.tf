variable "aws_region" {
  description = "Región de AWS donde se desplegarán los recursos."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente de despliegue (dev, staging, prod, etc.)."
  type        = string
  default     = "dev"
}

variable "aws_account_id" {
  description = "Número de cuenta de AWS."
  type        = string
}

variable "name_prefix" {
  description = "Prefijo para nombrar recursos de forma consistente."
  type        = string
  default     = "sensor"
}

# Ejemplo de variable extra para recursos
variable "extra_tags" {
  description = "Mapa de etiquetas adicionales para los recursos."
  type        = map(string)
  default     = {}
}

variable "iot_device_names" {
  description = "Lista de nombres de dispositivos IoT (things) a crear o gestionar."
  type        = list(string)
  default     = []
}

variable "iot_rules" {
  description = "Lista de reglas IoT a crear, cada una como un objeto con sus parámetros."
  type = list(object({
    rule_name      = string
    sql            = string
    s3_bucket_name = string
    s3_key         = string
    s3_canned_acl  = string
    role_arn       = string
  }))
  default = []
}
