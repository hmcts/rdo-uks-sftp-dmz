
/* 
# Need to address once backend 
resource "azurerm_network_security_rule" "ansible_2_sftp_host" {
  name                                          = "Ansible_to_sftp_hosts"
  description		                                = "Ansible_to_sftp_hosts"
  priority                                      = 210
  direction                                     = "Inbound"
  access                                        = "Allow"
  protocol                                      = "*"
  source_port_range                             = "*"
  destination_port_range                        = "*"
  source_address_prefix                         = "${azurerm_subnet.subnet-dmz-mgmt.address_prefix}"
  destination_address_prefix                    = "${azurerm_subnet.subnet-dmz-sftp.address_prefix}"
  resource_group_name                           = "${azurerm_resource_group.rg_sftp.name}"
  network_security_group_name                   = "${data.azurerm_network_security_group.sg-nsg-sftp.name}"
}


resource "azurerm_network_security_rule" "ansible_2_mgmt_host" {
  name                                          = "Ansible_to_mgmt_hosts"
  description		                                = "Ansible_to_mgmt_hosts"
  priority                                      = 211
  direction                                     = "Inbound"
  access                                        = "Allow"
  protocol                                      = "*"
  source_port_range                             = "*"
  destination_port_range                        = "*"
  source_address_prefix                         = "${data.azurerm_subnet.subnet-dmz-mgmt.address_prefix}"
  destination_address_prefix                    = "${data.azurerm_subnet.subnet-dmz-sftp.address_prefix}"
  resource_group_name                           = "${azurerm_resource_group.rg_sftp.name}"
  network_security_group_name                   = "${data.azurerm_network_security_group.sg-nsg-mgmt.name}"
}


resource "azurerm_network_security_rule" "ftp_ftps_21" {
  name                                          = "ftp_ftps_port_21"
  description                                   = "external ftp ftps access to DMZ Gateways"
  priority                                      = 221
  direction                                     = "Inbound"
  access                                        = "Allow"
  protocol                                      = "Tcp"
  source_port_range                             = "*"
  destination_port_range                        = "21"
  source_address_prefix                         = "213.121.161.124/32"
  destination_address_prefix                    = "*"
  resource_group_name                           = "${azurerm_resource_group.rg_sftp.name}"
  network_security_group_name                   = "${data.azurerm_network_security_group.sg-nsg-sftp.name}"
}

resource "azurerm_network_security_rule" "sftp_ssh_22" {
  name                                          = "sft_ssh_port_22"
  description                                   = "external sftp_ssh access to DMZ gateway"
  priority                                      = 222
  direction                                     = "Inbound"
  access                                        = "Allow"
  protocol                                      = "Tcp"
  source_port_range                             = "*"
  destination_port_range                        = "22"
  source_address_prefix                         = "213.121.161.124/32"
  destination_address_prefix                    = "*"
  resource_group_name                           = "${azurerm_resource_group.rg_sftp.name}"
  network_security_group_name                   = "${data.azurerm_network_security_group.sg-nsg-sftp.name}"
}


resource "azurerm_network_security_rule" "Passive-range" {
  name                                          = "passive-27001-28000"
  description                                   = "external http access to DMZ gateway"
  priority                                      = 223
  direction                                     = "Inbound"
  access                                        = "Allow"
  protocol                                      = "Tcp"
  source_port_range                             = "*"
  destination_port_range                        = "27001-28000"
  source_address_prefix                         = "213.121.161.124/32"
  destination_address_prefix                    = "*"
  resource_group_name                           = "${azurerm_resource_group.rg_sftp.name}"
  network_security_group_name                   = "${data.azurerm_network_security_group.sg-nsg-sftp.name}"
}

resource "azurerm_network_security_rule" "https_443" {
  name                                          = "https_port_443"
  description                                   = "external https access to DMZ gateway"
  priority                                      = 224
  direction                                     = "Inbound"
  access                                        = "Allow"
  protocol                                      = "Tcp"
  source_port_range                             = "*"
  destination_port_range                        = "443"
  source_address_prefix                         = "213.121.161.124/32"
  destination_address_prefix                    = "*"
  resource_group_name                           = "${azurerm_resource_group.rg_sftp.name}"
  network_security_group_name                   = "${data.azurerm_network_security_group.sg-nsg-sftp.name}"
}

resource "azurerm_network_security_rule" "port_990" {
  name                                          = "port_990"
  description                                   = "external 990 access to DMZ gateway"
  priority                                      = 225
  direction                                     = "Inbound"
  access                                        = "Allow"
  protocol                                      = "Tcp"
  source_port_range                             = "*"
  destination_port_range                        = "990"
  source_address_prefix                         = "213.121.161.124/32"
  destination_address_prefix                    = "*"
  resource_group_name                           = "${azurerm_resource_group.rg_sftp.name}"
  network_security_group_name                   = "${data.azurerm_network_security_group.sg-nsg-sftp.name}"
}


resource "azurerm_network_security_rule" "rdp_admin_to_public_from_office" {
  name                                          = "rdp_admin_to_public_from_office"
  description		                                = "allows RDP"
  priority                                      = 227
  direction                                     = "Inbound"
  access                                        = "Allow"
  protocol                                      = "Tcp"
  source_port_range                             = "*"
  destination_port_range                        = "3389"
  source_address_prefix                         = "213.121.161.124/32"
  destination_address_prefix                    = "*"
  resource_group_name                           = "${azurerm_resource_group.rg_sftp.name}"
  network_security_group_name                   = "${data.azurerm_network_security_group.sg-nsg-sftp.name}"
}

resource "azurerm_network_security_rule" "inbound_44500" {
  name                                          = "44500_port"
  description		                                = "Port between Public and Private"
  priority                                      = 228
  direction                                     = "Inbound"
  access                                        = "Allow"
  protocol                                      = "Tcp"
  source_port_range                             = "44500"
  destination_port_range                        = "44500"
  source_address_prefix                         = "VirtualNetwork"
  #source_address_prefix                         = "${azurerm_subnet.subnet_private.address_prefix}"
  destination_address_prefix                    = "VirtualNetwork"
  resource_group_name                           = "${azurerm_resource_group.rg_sftp.name}"
  network_security_group_name                   = "${data.azurerm_network_security_group.sg-nsg-sftp.name}"
}


resource "azurerm_subnet_network_security_group_association" "nsg_sftp" {
  subnet_id                       = "${azurerm_subnet.subnet-sftp.id}"
  network_security_group_id       = "${azurerm_network_security_group.nsg_mgmt.id}"
}

*/