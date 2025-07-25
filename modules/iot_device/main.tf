resource "aws_iot_thing" "this" {
  name = var.thing_name
}

resource "aws_iot_certificate" "this" {
  active = true
}

resource "aws_iot_policy" "this" {
  name   = "${var.thing_name}_policy"
  policy = var.policy_document
}

resource "aws_iot_policy_attachment" "this" {
  policy      = aws_iot_policy.this.name
  target      = aws_iot_certificate.this.arn
}

resource "aws_iot_thing_principal_attachment" "this" {
  thing       = aws_iot_thing.this.name
  principal   = aws_iot_certificate.this.arn
}
