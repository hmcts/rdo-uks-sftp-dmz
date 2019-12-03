resource "azurerm_virtual_machine" "dmz" {
  name                                      = "${var.rg_name}-vm-${count.index}"
  location                                  = "${var.rg_location}"
  resource_group_name                       = "${azurerm_resource_group.rg_sftp.name}"
  primary_network_interface_id              = "${element(azurerm_network_interface.mgmt_server_nic.*.id, count.index)}"
  network_interface_ids                     = ["${element(azurerm_network_interface.mgmt_server_nic.*.id, count.index)}", "${element(azurerm_network_interface.data_server_nic.*.id, count.index)}"]
  vm_size                                   = "Standard_B4ms"
  count                                     = "${var.environment == "sbox" ? 1 : 0}"
  delete_os_disk_on_termination             = true
 

  storage_image_reference {
    publisher                               = "MicrosoftWindowsServer"
    offer                                   = "WindowsServer"
    sku                                     = "2016-Datacenter"
    version                                 = "latest"
  }
 
   storage_os_disk {
    name                                    = "${var.rg_name}-os-${count.index}"
    caching                                 = "ReadWrite"
    create_option                           = "FromImage"
    managed_disk_type                       = "Standard_LRS"
  }
  os_profile {
    computer_name                           = "dmz-${count.index}"
    admin_username                          = "${var.admin-username}"
    admin_password                          = "${var.admin-password}"
  }

  os_profile_windows_config {
    provision_vm_agent                      = true 
    winrm {
      protocol                              = "http"
      }
  }  

  tags                                      = var.common_tags
}


# 
# https://raw.githubusercontent.com/hmcts/rdo-uks-sftp-dmz/master/scripts/ConfigureRemotingForAnsible.ps1?token=AA5K2ONGTU65L2UYJMTNMCS5IQHUE


resource "azurerm_virtual_machine_extension" "dmz" {
    name                                    = "ansible-config-windows"
    location                                = "${var.rg_location}"
    resource_group_name                     = "${azurerm_resource_group.rg_sftp.name}"
    virtual_machine_name                    = "${element(azurerm_virtual_machine.dmz.*.name, count.index)}" 
    publisher                               = "Microsoft.Compute"
    type                                    = "CustomScriptExtension"
    depends_on                              = ["azurerm_virtual_machine.dmz"]
    type_handler_version                    = "1.9"
    count                                   = "${var.environment == "sbox" ? 1 : 0}"
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
        username = "${var.admin-username}"
        admin_pass = "${var.admin-password}"
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

