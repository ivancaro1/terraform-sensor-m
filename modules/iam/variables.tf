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

variable "default_tags" {
  description = "Tags por defecto para todos los roles de IAM."
  type        = map(string)
  default     = {}
}