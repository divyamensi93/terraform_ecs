output "arn" {
  value = aws_iam_role.r.arn
}

output "instance_profile" {
  value = aws_iam_instance_profile.ip.name
}

output "name" {
  value = aws_iam_role.r.name
}
