# Ansible Control Host

resource "azurerm_virtual_machine" "ansible-host" {
  name                                      = "${var.rg_name}-ansible-${count.index}"
  location                                  = "${var.rg_location}"
  resource_group_name                       = "${azurerm_resource_group.rg_sftp.name}"
  network_interface_ids                     = ["${element(azurerm_network_interface.ansible_server_nic.*.id, count.index)}"]
  vm_size                                   = "Standard_B1s"
  count                                     = var.environment == "sbox" ? 1 : 0

  delete_os_disk_on_termination             = true
  
  storage_image_reference {
    publisher                               = "Canonical"
    offer                                   = "UbuntuServer"
    sku                                     = "18.04-LTS"
    version                                 = "latest"
  }
  
  storage_os_disk {
    name                                    = "${var.rg_name}-ansible-os"   
    caching                                 = "ReadWrite"
    create_option                           = "FromImage"
    managed_disk_type                       = "Standard_LRS"
  }
  
  os_profile {
    computer_name                           = "${var.rg_name}-ansible" 
    admin_username                          = "${var.admin-username}"
    admin_password                          = "${var.admin-password}"
  }


provisioner "remote-exec" {
    inline                                  = [
      "mkdir ~/ansible"
    ]
      connection {
    type                                    = "ssh"
    user                                    = "${var.admin-username}"
    password                                = "${var.admin-password}"
    host                                    = "${azurerm_public_ip.pip-ansible.*.ip_address}"
 }
}


  os_profile_linux_config {
    disable_password_authentication         = false
  }

  tags                                      = var.common_tags
}    

resource "azurerm_virtual_machine_extension" "ansible_extension" {
  name                                      = "Ansible-Agent-Install-${count.index}"
  location                                  = "${azurerm_resource_group.rg_sftp.location}"
  resource_group_name                       = "${azurerm_resource_group.rg_sftp.name}"
  virtual_machine_name                      = "${azurerm_virtual_machine.ansible-host.0.name}"
  publisher                                 = "Microsoft.Azure.Extensions"
  type                                      = "CustomScript"
  type_handler_version                      = "2.0"
  count                                     = var.environment == "sbox" ? 1 : 0

  settings = <<SETTINGS
    {
        "commandToExecute": "sudo apt-add-repository --yes --update ppa:ansible/ansible",
        "commandToExecute": "sudo apt-get update && sudo apt install -y software-properties-common ansible libssl-dev libffi-dev python-dev python-pip && sudo pip install pywinrm && sudo pip install azure-keyvault"
    }
SETTINGS
}



resource "azurerm_public_ip" "pip-ansible" {
  name                                      = "${var.rg_name}-ansible-pip-${count.index}"
  location                                  = "${var.rg_location}"
  resource_group_name                       = "${azurerm_resource_group.rg_sftp.name}"
  allocation_method                         = "Static"
  count                                     = var.environment == "sbox" ? 1 : 0

  tags                                      = var.common_tags
 }

resource "azurerm_network_interface" "ansible_server_nic" {
  name                                      = "${var.rg_name}-ansible-nic-${count.index}"
  location                                  = "${var.rg_location}"
  resource_group_name                       = "${azurerm_resource_group.rg_sftp.name}"
    ip_configuration {
        name                                = "${var.rg_name}-ansible-ip"
        subnet_id                           = "${azurerm_subnet.subnet-sftp.id}"
        private_ip_address_allocation       = "dynamic"
        public_ip_address_id                = "${element(azurerm_public_ip.pip-ansible.*.id, count.index)}"
    }
  count                                     = var.environment == "sbox" ? 1 : 0
  tags                                      = var.common_tags
}

resource "null_resource" "ansible-runs" {
    triggers = {
      always_run = "${timestamp()}"
    }

  count                                     = var.environment == "sbox" ? 1 : 0

    depends_on = [
        "azurerm_virtual_machine_extension.dmz",
        "azurerm_network_interface.ansible_server_nic",
        "azurerm_public_ip.pip-ansible",
        "azurerm_virtual_machine_extension.ansible_extension",
        "azurerm_virtual_machine.ansible-host"
    ]

  provisioner "file" {
    source                                  = "${path.module}/ansible/"
    destination                             = "~/ansible/"
  
    connection {
      type                                  = "ssh"
      user                                  = "${var.admin-username}"
      password                              = "${var.admin-password}"
      host                                  = "${azurerm_public_ip.pip-ansible.0.ip_address}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "ansible-playbook -i ~/ansible/inventory ~/ansible/playbooks/dmz-hosts.yml --extra-vars 'smtp_email=${var.smtp-email-address}' --extra-vars 'smtp_pass=${var.smtp-password}' --extra-vars 'gw_address=${var.hub-az-firewall}' --extra-vars 'palo_public=${data.azurerm_subnet.subnet-palo-public.address_prefix}' --extra-vars 'palo_private=${data.azurerm_subnet.subnet-palo-private.address_prefix}'"
    ]


    connection {
      type                                  = "ssh"
      user                                  = "${var.admin-username}"
      password                              = "${var.admin-password}"
      host                                  = "${azurerm_public_ip.pip-ansible.0.ip_address}"
    }
  }
}
