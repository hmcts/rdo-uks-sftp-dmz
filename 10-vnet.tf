resource "azurerm_virtual_network" "vnet" {
    name                              = "${data.azurerm_virtual_network.name}"
    address_space                     = ["${data.azurerm_virtual_network.vnet-dmz.address_space}"]
    location                          = "${var.location}"
    resource_group_name               = "${data.azurerm_resource_group.rg.name}"
    tags                              = "${var.tags}"
}
