output "role_names" {
  description = "Nombres de todos los roles de IAM creados."
  value       = [for role in aws_iam_role.this : role.name]
}

output "role_arns" {
  description = "ARNs de todos los roles de IAM creados."
  value       = [for role in aws_iam_role.this : role.arn]
}

output "role_by_name" {
  description = "Mapa de roles por nombre."
  value       = { for role in aws_iam_role.this : role.name => role.arn }
}