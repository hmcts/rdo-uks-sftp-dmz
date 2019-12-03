
data "azurerm_resource_group" "dmz" {
  name                                      = "hmcts-dmz-${var.environment}"
}

data "azurerm_subnet" "subnet-palo-public" {
  name                                      = "dmz-palo-public"
  virtual_network_name                      = "${data.azurerm_resource_group.dmz.name}"
  resource_group_name                       = "${data.azurerm_resource_group.dmz.name}"
}

data "azurerm_subnet" "subnet-palo-private" {
  name                                      = "dmz-palo-private"
  virtual_network_name                      = "${data.azurerm_resource_group.dmz.name}"
  resource_group_name                       = "${data.azurerm_resource_group.dmz.name}"
}



