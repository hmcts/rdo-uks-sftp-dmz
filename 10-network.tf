resource "azurerm_virtual_network" "vnet" {
    name                              = "${var.name}-vnet"
    address_space                     = ["${var.vnet}192.0/23"]
    location                          = "${var.location}"
    resource_group_name               = "${data.azurerm_resource_group.rg.name}"
    tags                              = "${var.tags}"
}


resource "azurerm_subnet" "subnet_public" {
    name                              = "${var.name}-public-subnet"
    resource_group_name               = "${data.azurerm_resource_group.rg.name}"
    virtual_network_name              = "${azurerm_virtual_network.vnet.name}"
    address_prefix                    = "${var.vnet}192.0/24"
    service_endpoints                 = ["Microsoft.Storage"]
    #network_security_group_id         = "${azurerm_network_security_group.public_nsg.id}"
    lifecycle {
        ignore_changes                = ["route_table_id", "network_security_group_id"]
    }
}

resource "azurerm_subnet" "subnet_mgmt" {
    name                              = "${var.name}-mgmt-subnet"
    resource_group_name               = "${data.azurerm_resource_group.rg.name}"
    virtual_network_name              = "${azurerm_virtual_network.vnet.name}"
    address_prefix                    = "${var.vnet}193.0/24"
    network_security_group_id         = "${azurerm_network_security_group.public_nsg.id}"
    lifecycle {
        ignore_changes                = ["route_table_id", "network_security_group_id"]
    }
}