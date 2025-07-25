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
