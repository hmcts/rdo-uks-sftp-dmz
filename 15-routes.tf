resource "azurerm_route_table" "rt" {
  name                              = "${var.vnet_name}-${var.environment}-udr"
  location                          = "${azurerm_resource_group.rg_dmz.location}"
  resource_group_name               = "${azurerm_resource_group.rg_dmz.name}"
  disable_bgp_route_propagation     = false

  route {
    name                            = "to_hub_fw"
    address_prefix                  = "0.0.0.0/0"
    next_hop_type                   = "VirtualAppliance"
    next_hop_in_ip_address          = "${local.palo_ip}"
  }
}

resource "azurerm_subnet_route_table_association" "route_association" {
  subnet_id                         = "${azurerm_subnet.subnet.1.id}"
  route_table_id                    = "${azurerm_route_table.rt.id}"
}

