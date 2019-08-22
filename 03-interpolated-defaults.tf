
data "azurerm_resource_group" "rg" {
  name                                = "${var.name}-rg"
}
 
data "azurerm_key_vault_secret" "admin-password" {
name = "admin-password"
key_vault_id = "${var.key_vault_uri}"
}

data "azurerm_key_vault_secret" "admin-username" {
name = "admin-username"
key_vault_id = "${var.key_vault_uri}"
}

data "azurerm_key_vault_secret" "smtp_email_address" {
name = "smtp-email-address"
key_vault_id = "${var.key_vault_uri}"
}

data "azurerm_key_vault_secret" "smtp_password" {
name = "smtp-password"
key_vault_id = "${var.key_vault_uri}"
}

data "azurerm_resource_group" "hub" {
  name                                      = "hub"
}

data "azurerm_network_interface" "palo_ip" {
  name                                      = "fw-sbox-nic-transit-private-0"
  resource_group_name                       = "${data.azurerm_resource_group.hub.name}"
}

locals {
  palo_ip                                   = "${data.azurerm_network_interface.palo_ip.private_ip_address}"
}