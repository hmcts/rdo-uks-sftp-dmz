# Ansible Control Host

resource "azurerm_virtual_machine" "ansible-host" {
  name                                      = "${var.name}-ansible"
  location                                  = "${var.location}"
  resource_group_name                       = "${data.azurerm_resource_group.rg.name}"
  network_interface_ids                     = ["${azurerm_network_interface.ansible_server_nic.id}"]
  vm_size                                   = "Standard_B1s"


  delete_os_disk_on_termination             = true
  
  storage_image_reference {
    publisher                               = "Canonical"
    offer                                   = "UbuntuServer"
    sku                                     = "18.04-LTS"
    version                                 = "latest"
  }
  
  storage_os_disk {
    name                                    = "${var.name}-ansible-os"   
    caching                                 = "ReadWrite"
    create_option                           = "FromImage"
    managed_disk_type                       = "Standard_LRS"
  }
  
  os_profile {
    computer_name                           = "${var.name}-ansible" 
    admin_username                          = "${data.azurerm_key_vault_secret.admin-username.value}"
    admin_password                          = "${data.azurerm_key_vault_secret.admin-password.value}"
  }


provisioner "remote-exec" {
    inline                                  = [
      "mkdir ~/ansible"
    ]
      connection {
    type                                    = "ssh"
    user                                    = "${data.azurerm_key_vault_secret.admin-username.value}"
    password                                = "${data.azurerm_key_vault_secret.admin-password.value}"
    host                                    = "${azurerm_public_ip.pip-ansible.ip_address}"
 }
}


  os_profile_linux_config {
    disable_password_authentication         = false
  }

  tags                                      = var.common_tags
}

resource "azurerm_virtual_machine_extension" "ansible_extension" {
  name                                      = "Ansible-Agent-Install"
  location                                  = "${var.location}"
  resource_group_name                       = "${data.azurerm_resource_group.rg.name}"
  virtual_machine_name                      = "${azurerm_virtual_machine.ansible-host.name}"
  publisher                                 = "Microsoft.Azure.Extensions"
  type                                      = "CustomScript"
  type_handler_version                      = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "sudo apt-add-repository --yes --update ppa:ansible/ansible",
        "commandToExecute": "sudo apt-get update && sudo apt install -y software-properties-common ansible libssl-dev libffi-dev python-dev python-pip && sudo pip install pywinrm && sudo pip install azure-keyvault"
    }
SETTINGS
}



resource "azurerm_public_ip" "pip-ansible" {
  name                                      = "${var.name}-ansible-pip"
  location                                  = "${var.location}"
  resource_group_name                       = "${data.azurerm_resource_group.rg.name}"
  allocation_method                         = "Static"

  tags                                      = var.common_tags
 }

resource "azurerm_network_interface" "ansible_server_nic" {
  name                                      = "${var.name}-ansible-nic"
  location                                  = "${var.location}"
  resource_group_name                       = "${data.azurerm_resource_group.rg.name}"
    ip_configuration {
        name                                = "${var.name}-ansible-ip"
        subnet_id                           = "${data.azurerm_subnet.subnet-dmz-mgmt.id}"
        private_ip_address_allocation       = "dynamic"
        public_ip_address_id                = "${azurerm_public_ip.pip-ansible.id}"
    }

  tags                                      = var.common_tags
}


resource "null_resource" "ansible-runs" {
    triggers = {
      always_run = "${timestamp()}"
    }

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
      user                                  = "${data.azurerm_key_vault_secret.admin-username.value}"
      password                              = "${data.azurerm_key_vault_secret.admin-password.value}"
      host                                  = "${azurerm_public_ip.pip-ansible.ip_address}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "ansible-playbook -i ~/ansible/inventory ~/ansible/playbooks/dmz-hosts.yml --extra-vars 'smtp_email=${data.azurerm_key_vault_secret.smtp_email_address.value}' --extra-vars 'smtp_pass=${data.azurerm_key_vault_secret.smtp_password.value}' --extra-vars 'proxy_ip=${data.azurerm_network_interface.proxy_private_ip.private_ip_address}' --extra-vars 'proxy_bypass_hosts=10' --extra-vars 'gw_address=${local.default_gateway}' --extra-vars 'palo_public=${data.azurerm_subnet.subnet-palo-public.address_prefix}' --extra-vars 'palo_private=${data.azurerm_subnet.subnet-palo-private.address_prefix}'"
    ]


    connection {
      type                                  = "ssh"
      user                                  = "${data.azurerm_key_vault_secret.admin-username.value}"
      password                              = "${data.azurerm_key_vault_secret.admin-password.value}"
      host                                  = "${azurerm_public_ip.pip-ansible.ip_address}"
    }
  }
}
