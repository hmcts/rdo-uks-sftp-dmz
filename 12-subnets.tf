
resource "azurerm_subnet" "subnet-sftp" {
  name                            = "subnet-${var.rg_name}"
  resource_group_name             = "${azurerm_resource_group.rg_sftp.name}"
  virtual_network_name            = "${azurerm_virtual_network.vnet_sftp.name}"
  address_prefix                  = "10.97.0.0/24"
}


