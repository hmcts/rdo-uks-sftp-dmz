resource "azurerm_virtual_network" "vnet_sftp" {
  name                            = "${var.rg_name}-vn"
  location                        = "${azurerm_resource_group.rg_sftp.location}"
  resource_group_name             = "${azurerm_resource_group.rg_sftp.name}"
  address_space                   = ["10.97.0.0/24]

  tags                            = var.common_tags
}
