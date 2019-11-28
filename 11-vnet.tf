resource "azurerm_virtual_network" "vnet_dmz" {
  name                            = "${var.vnet_name}"
  location                        = "${azurerm_resource_group.rg_sftp.location}"
  resource_group_name             = "${azurerm_resource_group.rg_sftp.name}"
  address_space                   = ["${var.vnet_cidr}"]

  tags                            = var.common_tags
}
