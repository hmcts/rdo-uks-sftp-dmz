data "http" "myip" {
  url = "http://v4.ident.me"
}

data "azurerm_resource_group" "rg" {
  name                                = "${var.name}-rg"
}
 
data "azurerm_key_vault_secret" "admin-password" {
name = "admin-password"
vault_uri = "${var.key_vault_uri}"
}

data "azurerm_key_vault_secret" "admin-username" {
name = "admin-username"
vault_uri = "${var.key_vault_uri}"
}

data "azurerm_key_vault_secret" "smtp_email_address" {
name = "smtp-email-address"
vault_uri = "${var.key_vault_uri}"
}

data "azurerm_key_vault_secret" "smtp_password" {
name = "smtp-password"
vault_uri = "${var.key_vault_uri}"
}

resource "azurerm_virtual_network" "vnet" {
    name                              = "${var.name}-vnet"
    address_space                     = ["${var.vnet}60.0/24"]
    location                          = "${var.location}"
    resource_group_name               = "${data.azurerm_resource_group.rg.name}"
    tags                              = "${var.tags}"
}


resource "azurerm_subnet" "subnet_public" {
    name                              = "${var.name}-public-subnet"
    resource_group_name               = "${data.azurerm_resource_group.rg.name}"
    virtual_network_name              = "${azurerm_virtual_network.vnet.name}"
    address_prefix                    = "${var.vnet}60.0/24"
    service_endpoints                 = ["Microsoft.Storage"]
    network_security_group_id         = "${azurerm_network_security_group.public_nsg.id}"
}