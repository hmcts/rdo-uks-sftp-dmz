
resource "azurerm_public_ip" "pip-public" {
   name                                     = "${var.name}-mgmt-pip-${count.index}"
   location                                 = "${var.location}"
   resource_group_name                      = "${data.azurerm_resource_group.rg.name}"
   allocation_method                        = "Static"
   count                                    = "${var.vm_count}"
   tags                                     = "${var.tags}"
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
   tags                                     = "${var.tags}"
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
   tags                                     = "${var.tags}"
}

resource "azurerm_virtual_machine" "dmz" {
  name                                      = "${var.name}-vm-${count.index}"
  location                                  = "${var.location}"
  resource_group_name                       = "${data.azurerm_resource_group.rg.name}"
  primary_network_interface_id              = "${element(azurerm_network_interface.mgmt_server_nic.*.id, count.index)}"
  network_interface_ids                     = ["${element(azurerm_network_interface.mgmt_server_nic.*.id, count.index)}", "${element(azurerm_network_interface.data_server_nic.*.id, count.index)}"]
  vm_size                                   = "Standard_B4ms"
  count                                     = "${var.vm_count}"
  delete_os_disk_on_termination             = true
  tags                                      = "${var.tags}"

  storage_image_reference {
    publisher                               = "MicrosoftWindowsServer"
    offer                                   = "WindowsServer"
    sku                                     = "2016-Datacenter"
    version                                 = "latest"
  }
 
   storage_os_disk {
    name                                    = "${var.name}-os-${count.index}"
    caching                                 = "ReadWrite"
    create_option                           = "FromImage"
    managed_disk_type                       = "Standard_LRS"
  }
  os_profile {
    computer_name                           = "dmz-${count.index}"
    admin_username                          = "${data.azurerm_key_vault_secret.admin-username.value}"
    admin_password                          = "${data.azurerm_key_vault_secret.admin-password.value}"
  }

  os_profile_windows_config {
    provision_vm_agent                      = true 
    winrm {
      protocol                              = "http"
      }
  }  

}


# 
# https://raw.githubusercontent.com/hmcts/rdo-uks-sftp-dmz/master/scripts/ConfigureRemotingForAnsible.ps1?token=AA5K2ONGTU65L2UYJMTNMCS5IQHUE


resource "azurerm_virtual_machine_extension" "dmz" {
    name                                    = "ansible-config-windows"
    location                                = "${var.location}"
    resource_group_name                     = "${data.azurerm_resource_group.rg.name}"
    virtual_machine_name                    = "${element(azurerm_virtual_machine.dmz.*.name, count.index)}" 
    publisher                               = "Microsoft.Compute"
    type                                    = "CustomScriptExtension"
    depends_on                              = ["azurerm_virtual_machine.dmz"]
    type_handler_version                    = "1.9"
    count                                   = "${var.vm_count}"
    settings = <<SETTINGS
    {
        "fileUris": [
            "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
        ],
        "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ./ConfigureRemotingForAnsible.ps1"
    }
    SETTINGS
}


data "template_file" "inventory" {
    template = "${file("${path.module}/template/inventory.tpl")}"

    depends_on = [
        "azurerm_virtual_machine.dmz",
        "azurerm_network_interface.data_server_nic",
        "azurerm_virtual_machine_extension.dmz",
        "azurerm_public_ip.pip-public"
        
    ]

    vars = {
        public_ip = "${join("\n", azurerm_network_interface.mgmt_server_nic.*.private_ip_address)}"  
        username = "${data.azurerm_key_vault_secret.admin-username.value}"
        admin_pass = "${data.azurerm_key_vault_secret.admin-password.value}"
    }
}

resource "null_resource" "update_inventory" {

    depends_on = [
        "azurerm_virtual_machine.dmz",
        "azurerm_network_interface.data_server_nic",
        "azurerm_virtual_machine_extension.dmz",
        "azurerm_public_ip.pip-public"
    ]
    triggers = {
        template = "${data.template_file.inventory.rendered}"
    }

    provisioner "local-exec" {
        command = "echo '${data.template_file.inventory.rendered}' > ${path.module}/ansible/inventory"
    }
}

# Ansible Control Host

resource "azurerm_virtual_machine" "ansible-host" {
  name                                      = "${var.name}-ansible"
  location                                  = "${var.location}"
  resource_group_name                       = "${data.azurerm_resource_group.rg.name}"
  network_interface_ids                     = ["${azurerm_network_interface.ansible_server_nic.id}"]
  vm_size                                   = "Standard_B1s"
  tags                                      = "${var.tags}"

  delete_os_disk_on_termination = true

#   storage_image_reference {
#     publisher = "center-for-internet-security-inc"
#     offer     = "cis-ubuntu-linux-1804-l1"
#     sku       = "cis-ubuntu1804-l1"
#     version   = "latest"
#   }
  
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
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
    inline = [
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
   name                                     = "${var.name}-ansible-pip"
   location                                 = "${var.location}"
   resource_group_name                      = "${data.azurerm_resource_group.rg.name}"
   allocation_method                        = "Static"
  tags                                      = "${var.tags}"
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
  tags                                      = "${var.tags}"
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
      type     = "ssh"
      user     = "${data.azurerm_key_vault_secret.admin-username.value}"
      password = "${data.azurerm_key_vault_secret.admin-password.value}"
      host     = "${azurerm_public_ip.pip-ansible.ip_address}"
    }
  }
}
