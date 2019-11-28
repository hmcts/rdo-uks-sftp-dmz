resource "azurerm_resource_group" "rg_sftp" {
  name                            = var.rg_name
  location                        = var.rg_location

  tags                            = var.common_tags
}
