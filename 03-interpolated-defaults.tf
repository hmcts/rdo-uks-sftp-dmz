
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

data "azurerm_resource_group" "hub" {
  name                                      = "hub"
}

data "azurerm_network_interface" "palo_ip" {
  name                                      = "${data.azurerm_resource_group.hub-rg.name}-sbox-nic-transit-private-0"
  resource_group_name                       = "${data.azurerm_resource_group.hub.name}"
}

locals {
  palo_ip                                   = "${data.azurerm_network_interface.palo_ip.private_ip_address}"
}

data "azurerm_resource_group" "dmz" {
  name                                      = "dmz"
}

data "azurerm_virtual_network" "vnet-dmz" {
  name                                      = "${data.azurerm_resource_group.dmz.name}-${var.environment}"
  resource_group_name                       = "${data.azurerm_resource_group.dmz.name}"
}

data "azurerm_subnet" "subnet-dmz-sftp" {
  name                                      = "dmz-sftp"
  virtual_network_name                      = "${data.azurerm_resource_group.dmz.name}-${var.environment}"
  resource_group_name                       = "${data.azurerm_resource_group.dmz.name}"
}

data "azurerm_subnet" "subnet-dmz-mgmt" {
  name                                      = "dmz-mgmt"
  virtual_network_name                      = "${data.azurerm_resource_group.dmz.name}-${var.environment}"
  resource_group_name                       = "${data.azurerm_resource_group.dmz.name}"
}

data "azurerm_network_security_group" "sg-nsg-sftp" {
  name                                      = "nsg_sftp"
  resource_group_name                       = "${data.azurerm_resource_group.dmz.name}"
}