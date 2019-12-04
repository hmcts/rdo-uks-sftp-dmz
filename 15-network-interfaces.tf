resource "azurerm_public_ip" "pip-public" {
   name                                     = "${var.rg_name}-mgmt-pip-${count.index}"
   location                                 = "${var.rg_location}"
   resource_group_name                      = "${azurerm_resource_group.rg_sftp.name}"
   allocation_method                        = "Static"
   count                                    = var.environment == "sbox" ? 2 : 0
   tags                                     = var.common_tags
 }



 resource "azurerm_network_interface" "mgmt_server_nic" {
  name                                      = "${var.rg_name}-mgmt-nic-${count.index}"
  location                                  = "${var.rg_location}"
  resource_group_name                       = "${azurerm_resource_group.rg_sftp.name}"
  #network_security_group_id                 = "${azurerm_network_security_group.public_nsg.id}"
  count                                     = var.environment == "sbox" ? 2 : 0
    ip_configuration {
        name                                = "${var.rg_name}-mgmt-ip-${count.index}"
        subnet_id                           = "${azurerm_subnet.subnet-sftp.id}"
        private_ip_address_allocation       = "dynamic"
        public_ip_address_id                = "${element(azurerm_public_ip.pip-public.*.id, count.index)}"
    }

  tags                            = var.common_tags
}



resource "azurerm_network_interface" "data_server_nic" {
  name                                      = "${var.rg_name}-data-nic-${count.index}"
  location                                  = "${var.rg_location}"
  resource_group_name                       = "${azurerm_resource_group.rg_sftp.name}"
  #network_security_group_id                 = "${azurerm_network_security_group.public_nsg.id}"
  count                                     = var.environment == "sbox" ? 2 : 0
    ip_configuration {
        name                                = "${var.rg_name}-data-ip-${count.index}"
        subnet_id                           = "${azurerm_subnet.subnet-sftp.id}"
        private_ip_address_allocation       = "dynamic"
    }

  tags                                      = var.common_tags
}
