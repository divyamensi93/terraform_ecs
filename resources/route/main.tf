resource "aws_route" "rule" {
  count          = length(var.route_tables)
  route_table_id = var.route_tables[count.index]

  destination_cidr_block      = var.destination_cidr_block
  destination_ipv6_cidr_block = var.destination_ipv6_cidr_block

  egress_only_gateway_id    = length(var.egress_only_gateways) != 0 ? var.egress_only_gateways[min(length(var.egress_only_gateways) - 1, count.index)] : ""
  gateway_id                = length(var.gateway_ids) != 0 ? var.gateway_ids[min(length(var.gateway_ids) - 1, count.index)] : ""
  instance_id               = length(var.instances) != 0 ? var.instances[min(length(var.instances) - 1, count.index)] : ""
  nat_gateway_id            = length(var.nat_gateways) != 0 ? var.nat_gateways[min(length(var.nat_gateways) - 1, count.index)] : ""
  network_interface_id      = length(var.network_interfaces) != 0 ? var.network_interfaces[min(length(var.network_interfaces) - 1, count.index)] : ""
  transit_gateway_id        = length(var.transit_gateways) != 0 ? var.transit_gateways[min(length(var.transit_gateways) - 1, count.index)] : ""
  vpc_peering_connection_id = length(var.vpc_peering_connections) != 0 ? var.vpc_peering_connections[min(length(var.vpc_peering_connections) - 1, count.index)] : ""
}

