
data "azurerm_resource_group" "rg" {
  name                                      = "${var.rg_name}-rg"
}
 
data "azurerm_key_vault_secret" "admin-password" {
name                                        = "admin-password"
vault_uri                                   = "${var.key_vault_uri}"
}

data "azurerm_key_vault_secret" "admin-username" {
name                                        = "admin-username"
vault_uri                                   = "${var.key_vault_uri}"
}

data "azurerm_key_vault_secret" "smtp_email_address" {
name                                        = "smtp-email-address"
vault_uri                                   = "${var.key_vault_uri}"
}

data "azurerm_key_vault_secret" "smtp_password" {
name                                        = "smtp-password"
vault_uri                                   = "${var.key_vault_uri}"
}

data "azurerm_resource_group" "hub" {
  name                                      = "hub"
}

data "azurerm_resource_group" "dmz" {
  name                                      = "dmz"
}

data "azurerm_subnet" "subnet-dmz-sftp" {
  name                                      = "dmz-sftp"
  virtual_network_name                      = "${data.azurerm_resource_group.dmz.name}"
  resource_group_name                       = "${data.azurerm_resource_group.dmz.name}"
}

data "azurerm_subnet" "subnet-dmz-mgmt" {
  name                                      = "dmz-mgmt"
  virtual_network_name                      = "${data.azurerm_resource_group.dmz.name}"
  resource_group_name                       = "${data.azurerm_resource_group.dmz.name}"
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

data "azurerm_network_security_group" "sg-nsg-sftp" {
  name                                      = "nsg_sftp"
  resource_group_name                       = "${data.azurerm_resource_group.dmz.name}"
}

data "azurerm_network_security_group" "sg-nsg-mgmt" {
  name                                      = "nsg_mgmt"
  resource_group_name                       = "${data.azurerm_resource_group.dmz.name}"
}

data "azurerm_network_interface" "proxy_private_ip" {
  name                                      = "proxy-sbox-nic"
  resource_group_name                       = "${data.azurerm_resource_group.dmz.name}"
}

locals {
  default_gateway                           = "${cidrhost(data.azurerm_subnet.subnet-dmz-sftp.address_prefix,1)}"
}