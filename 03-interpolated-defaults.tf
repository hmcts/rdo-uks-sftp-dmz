
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

/*

data "azurerm_network_interface" "proxy_private_ip" {
  name                                      = "proxy-sbox-nic"
  resource_group_name                       = "${data.azurerm_resource_group.dmz.name}"
}

locals {
  default_gateway                           = "${cidrhost(data.azurerm_subnet.subnet-dmz-sftp.address_prefix,1)}"
}
*/