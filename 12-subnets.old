
resource "azurerm_subnet" "subnet-mgmt" {
  name                            = "hub-mgmt"
  resource_group_name             = "${azurerm_resource_group.rg_hub.name}"
  virtual_network_name            = "${azurerm_virtual_network.vnet_hub.name}"
  address_prefix                  = "${var.subnet-mgmt-prefix}"
  network_security_group_id       = "${azurerm_network_security_group.nsg_mgmt.id}"
  lifecycle {
    ignore_changes                = ["route_table_id"]
  }

}

resource "azurerm_subnet" "subnet-private" {
  name                            = "hub-transit-private"
  resource_group_name             = "${azurerm_resource_group.rg_hub.name}"
  virtual_network_name            = "${azurerm_virtual_network.vnet_hub.name}"
  address_prefix                  = "${var.subnet-private-prefix}"
  network_security_group_id       = "${azurerm_network_security_group.nsg_transit_private.id}"
  lifecycle {
    ignore_changes                = ["route_table_id"]
  }

}


resource "azurerm_subnet" "subnet-public" {
  name                            = "hub-transit-public"
  resource_group_name             = "${azurerm_resource_group.rg_hub.name}"
  virtual_network_name            = "${azurerm_virtual_network.vnet_hub.name}"
  address_prefix                  = "${var.subnet-public-prefix}"
  network_security_group_id       = "${azurerm_network_security_group.nsg_transit_public.id}"
  lifecycle {
    ignore_changes                = ["route_table_id"]
  }

}

resource "azurerm_subnet" "subnet-azure-fw" {
  name                            = "AzureFirewallSubnet"
  resource_group_name             = "${azurerm_resource_group.rg_hub.name}"
  virtual_network_name            = "${azurerm_virtual_network.vnet_hub.name}"
  address_prefix                  = "${var.subnet-dmz-azure-fw-prefix}"
}


resource "azurerm_subnet_network_security_group_association" "nsg_mgmt" {
  subnet_id                       = "${azurerm_subnet.subnet-mgmt.id}"
  network_security_group_id       = "${azurerm_network_security_group.nsg_mgmt.id}"
}

resource "azurerm_subnet_network_security_group_association" "nsg_transit_private" {
  subnet_id                       = "${azurerm_subnet.subnet-private.id}"
  network_security_group_id       = "${azurerm_network_security_group.nsg_transit_private.id}"
}

resource "azurerm_subnet_network_security_group_association" "nsg_transit_public" {
  subnet_id                       = "${azurerm_subnet.subnet-public.id}"
  network_security_group_id       = "${azurerm_network_security_group.nsg_transit_public.id}"
}