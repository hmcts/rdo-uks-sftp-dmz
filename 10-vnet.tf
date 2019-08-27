resource "azurerm_virtual_network" "vnet" {
    name                              = "${data.azurerm_resource_group.dmz.name}"
    address_space                     = ["${data.azurerm_resource_group.dmz.address_space}"]
    location                          = "${var.location}"
    resource_group_name               = "${data.azurerm_resource_group.rg.name}"
    tags                              = "${var.tags}"
}
