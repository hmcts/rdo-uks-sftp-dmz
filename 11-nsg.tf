###
# NSG for DMZ / Public Access
###

resource "azurerm_network_security_group" "public_nsg" {
    name                                        = "${var.name}-nsg"
    location                                    = "${var.location}"
    resource_group_name                         = "${data.azurerm_resource_group.rg.name}"
    tags                                        = "${var.tags}"
}

resource "azurerm_network_security_rule" "ftp_ftps_21" {
  name                                          = "ftp_ftps_port_21"
  description                                   = "external ftp ftps access to DMZ Gateways"
  priority                                      = 121
  direction                                     = "Inbound"
  access                                        = "Allow"
  protocol                                      = "Tcp"
  source_port_range                             = "*"
  destination_port_range                        = "21"
  source_address_prefix                         = "213.121.161.124/32"
  destination_address_prefix                    = "${azurerm_subnet.subnet_public.address_prefix}"
  resource_group_name                           = "${data.azurerm_resource_group.rg.name}"
  network_security_group_name                   = "${azurerm_network_security_group.public_nsg.name}"
}

resource "azurerm_network_security_rule" "sftp_ssh_22" {
  name                                          = "sft_ssh_port_22"
  description                                   = "external sftp_ssh access to DMZ gateway"
  priority                                      = 122
  direction                                     = "Inbound"
  access                                        = "Allow"
  protocol                                      = "Tcp"
  source_port_range                             = "*"
  destination_port_range                        = "22"
  source_address_prefix                         = "213.121.161.124/32"
  destination_address_prefix                    = "${azurerm_subnet.subnet_public.address_prefix}"
  resource_group_name                           = "${data.azurerm_resource_group.rg.name}"
  network_security_group_name                   = "${azurerm_network_security_group.public_nsg.name}"
}

resource "azurerm_network_security_rule" "ssh_access_my_ip" {
  name                                          = "ssh_admin_access"
  description		                                = "allows SSH"
  priority                                      = 130
  direction                                     = "Inbound"
  access                                        = "Allow"
  protocol                                      = "Tcp"
  source_port_range                             = "*"
  destination_port_range                        = "22"
  source_address_prefix                         = "${data.http.myip.body}/32"
  destination_address_prefix                    = "${azurerm_subnet.subnet_public.address_prefix}"
  resource_group_name                           = "${data.azurerm_resource_group.rg.name}"
  network_security_group_name                   = "${azurerm_network_security_group.public_nsg.name}"
}


resource "azurerm_network_security_rule" "Passive-range" {
  name                                          = "passive-27001-28000"
  description                                   = "external http access to DMZ gateway"
  priority                                      = 123
  direction                                     = "Inbound"
  access                                        = "Allow"
  protocol                                      = "Tcp"
  source_port_range                             = "*"
  destination_port_range                        = "27001-28000"
  source_address_prefix                         = "213.121.161.124/32"
  destination_address_prefix                    = "${azurerm_subnet.subnet_public.address_prefix}"
  resource_group_name                           = "${data.azurerm_resource_group.rg.name}"
  network_security_group_name                   = "${azurerm_network_security_group.public_nsg.name}"
}

resource "azurerm_network_security_rule" "https_443" {
  name                                          = "https_port_443"
  description                                   = "external https access to DMZ gateway"
  priority                                      = 124
  direction                                     = "Inbound"
  access                                        = "Allow"
  protocol                                      = "Tcp"
  source_port_range                             = "*"
  destination_port_range                        = "443"
  source_address_prefix                         = "213.121.161.124/32"
  destination_address_prefix                    = "${azurerm_subnet.subnet_public.address_prefix}"
  resource_group_name                           = "${data.azurerm_resource_group.rg.name}"
  network_security_group_name                   = "${azurerm_network_security_group.public_nsg.name}"
}

resource "azurerm_network_security_rule" "port_990" {
  name                                          = "port_990"
  description                                   = "external 990 access to DMZ gateway"
  priority                                      = 125
  direction                                     = "Inbound"
  access                                        = "Allow"
  protocol                                      = "Tcp"
  source_port_range                             = "*"
  destination_port_range                        = "990"
  source_address_prefix                         = "213.121.161.124/32"
  destination_address_prefix                    = "${azurerm_subnet.subnet_public.address_prefix}"
  resource_group_name                           = "${data.azurerm_resource_group.rg.name}"
  network_security_group_name                   = "${azurerm_network_security_group.public_nsg.name}"
}

resource "azurerm_network_security_rule" "rdp_admin_access_my_ip" {
  name                                          = "rdp_admin_access"
  description		                                = "allows RDP"
  priority                                      = 126
  direction                                     = "Inbound"
  access                                        = "Allow"
  protocol                                      = "Tcp"
  source_port_range                             = "*"
  destination_port_range                        = "3389"
  source_address_prefix                         = "${data.http.myip.body}/32"
  destination_address_prefix                    = "${azurerm_subnet.subnet_public.address_prefix}"
  resource_group_name                           = "${data.azurerm_resource_group.rg.name}"
  network_security_group_name                   = "${azurerm_network_security_group.public_nsg.name}"
}

resource "azurerm_network_security_rule" "rdp_admin_to_public_from_office" {
  name                                          = "rdp_admin_to_public_from_office"
  description		                                = "allows RDP"
  priority                                      = 127
  direction                                     = "Inbound"
  access                                        = "Allow"
  protocol                                      = "Tcp"
  source_port_range                             = "*"
  destination_port_range                        = "3389"
  source_address_prefix                         = "213.121.161.124/32"
  destination_address_prefix                    = "${azurerm_subnet.subnet_public.address_prefix}"
  resource_group_name                           = "${data.azurerm_resource_group.rg.name}"
  network_security_group_name                   = "${azurerm_network_security_group.public_nsg.name}"
}

resource "azurerm_network_security_rule" "inbound_44500" {
  name                                          = "44500_port"
  description		                                = "Port between Public and Private"
  priority                                      = 128
  direction                                     = "Inbound"
  access                                        = "Allow"
  protocol                                      = "Tcp"
  source_port_range                             = "44500"
  destination_port_range                        = "44500"
  source_address_prefix                         = "*" #"${azurerm_subnet.subnet_private.address_prefix}"
  destination_address_prefix                    = "${azurerm_subnet.subnet_public.address_prefix}"
  resource_group_name                           = "${data.azurerm_resource_group.rg.name}"
  network_security_group_name                   = "${azurerm_network_security_group.public_nsg.name}"
}


resource "azurerm_network_security_rule" "ansible_ips" {
  name                                = "ansible_ips"
  description		                      = "ansible_ips"
  priority                            = 201
  direction                           = "Inbound"
  access                              = "Allow"
  protocol                            = "*"
  source_port_range                   = "*"
  destination_port_range              = "*"
  source_address_prefix               = "${azurerm_public_ip.pip-ansible.id}"
  destination_address_prefix          = "${azurerm_public_ip.pip-public.*.ip_address}"
  resource_group_name                 = "${data.azurerm_resource_group.rg.name}"
  network_security_group_name         = "${element(azurerm_network_security_group.public_nsg.*.name, 0)}"
}