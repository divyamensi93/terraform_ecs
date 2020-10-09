output "ids" {
  value = aws_subnet.sizing.*.id
}

output "route_tables" {
  value = aws_route_table.rt.*.id
}

