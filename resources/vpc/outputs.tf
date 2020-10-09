output "cidr_block" {
  value = aws_vpc.network.cidr_block
}

output "id" {
  value = aws_vpc.network.id
}

output "main_route_table_id" {
  value = aws_vpc.network.main_route_table_id
}
