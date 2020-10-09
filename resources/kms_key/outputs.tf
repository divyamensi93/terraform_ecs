output "cmk_arn" {
  value = aws_kms_key.cmk.arn
}

output "cmk_name" {
  value = aws_kms_alias.cmk_name.name_prefix
}

output "cmk_name_arn" {
  value = aws_kms_alias.cmk_name.arn
}

