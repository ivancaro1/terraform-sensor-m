resource "aws_iam_role" "this" {
  for_each = {
    for role in var.iam_roles : role.name => role
  }

  name               = each.value.name
  description        = each.value.description
  assume_role_policy = each.value.assume_role_policy
  tags               = each.value.tags

  # Inline policy solo para el rol "Glue"
  dynamic "inline_policy" {
    for_each = each.value.name == "Glue" ? [1] : []
    content {
      name   = "glue_inline"
      policy = file("${path.module}/../../policies/glue_inline_policy.json")
    }
  }
}

resource "aws_iam_role_policy_attachment" "managed_policies" {
  for_each = {
    for pair in setproduct(keys(aws_iam_role.this), flatten([
      for role in var.iam_roles : role.managed_policy_arns
    ])) : "${pair[0]}-${pair[1]}" => {
      role_name  = pair[0]
      policy_arn = pair[1]
    }
  }

  role       = aws_iam_role.this[each.value.role_name].name
  policy_arn = each.value.policy_arn
}