resource "azurerm_resource_group" "rg_sftp" {
  name                            = var.environment == "sbox" ? 1 : 0
  location                        = var.rg_location

  tags                            = var.common_tags
}
