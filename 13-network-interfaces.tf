resource "azurerm_public_ip" "pip-public" {
   name                                     = "${var.name}-mgmt-pip-${count.index}"
   location                                 = "${var.location}"
   resource_group_name                      = "${data.azurerm_resource_group.rg.name}"
   allocation_method                        = "Static"
   count                                    = "${var.vm_count}"
   tags                                     = var.common_tags
 }



 resource "azurerm_network_interface" "mgmt_server_nic" {
  name                                      = "${var.name}-mgmt-nic-${count.index}"
  location                                  = "${var.location}"
  resource_group_name                       = "${data.azurerm_resource_group.rg.name}"
  #network_security_group_id                 = "${azurerm_network_security_group.public_nsg.id}"
  count                                     = "${var.vm_count}"
    ip_configuration {
        name                                = "${var.name}-mgmt-ip-${count.index}"
        subnet_id                           = "${data.azurerm_subnet.subnet-dmz-mgmt.id}"
        private_ip_address_allocation       = "dynamic"
        public_ip_address_id                = "${element(azurerm_public_ip.pip-public.*.id, count.index)}"
    }

  tags                            = var.common_tags
}



resource "azurerm_network_interface" "data_server_nic" {
  name                                      = "${var.name}-data-nic-${count.index}"
  location                                  = "${var.location}"
  resource_group_name                       = "${data.azurerm_resource_group.rg.name}"
  #network_security_group_id                 = "${azurerm_network_security_group.public_nsg.id}"
  count                                     = "${var.vm_count}"
    ip_configuration {
        name                                = "${var.name}-data-ip-${count.index}"
        subnet_id                           = "${data.azurerm_subnet.subnet-dmz-sftp.id}"
        private_ip_address_allocation       = "dynamic"
    }

  tags                                      = var.common_tags
}
