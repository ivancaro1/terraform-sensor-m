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
  default     = "782659268170"
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

variable "glue_jobs" {
  description = "Mapa de jobs de Glue a crear, cada uno como un objeto con sus parámetros."
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
    schedule                 = string
  }))
  default = {}
}

variable "iam_roles" {
  description = "Lista de roles de IAM a crear, cada uno como un objeto con sus parámetros."
  type = list(object({
    name                    = string
    description            = string
    assume_role_policy     = string
    managed_policy_arns    = list(string)
    inline_policies        = map(string)
    tags                   = map(string)
  }))
  default = []
}

variable "glue_assets_bucket" {
  description = "Bucket donde se almacenan los scripts y assets de Glue"
  type        = string
}

variable "curated_sensordata_bucket" {
  description = "Bucket donde se almacenan los datos procesados (curados)"
  type        = string
}

variable "raw_sensordata_bucket" {
  description = "Bucket donde se almacenan los datos sin procesar (raw)"
  type        = string
}